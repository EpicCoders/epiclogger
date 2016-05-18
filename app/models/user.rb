class User < ActiveRecord::Base
  # include the TokenGenerator extension
  include TokenGenerator
  has_many :website_members, -> { uniq }, dependent: :destroy, autosave: true
  has_many :websites, through: :website_members

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, confirmation: true, on: :create
  has_secure_password(validations: false)

  before_create { generate_token(:uid) if provider == 'email' }
  before_create { generate_token(:confirmation_token) if confirmation_token.blank? }

  def is_owner_of?(website)
    website.website_members.with_role(:owner).where(website: website).map(&:user_id).include?(self.id)
  end

  def default_website
    websites.try(:first)
  end

  def avatar_url(size = 40)
    gravatar = Digest::MD5.hexdigest(email).downcase
    "http://gravatar.com/avatar/#{gravatar}.png?s=#{size}"
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["name"] || auth["info"]["nickname"]
      user.email = auth["info"]["email"]
    end
  end
end
