class User < ActiveRecord::Base
  has_many :website_members, -> { uniq }, dependent: :destroy, autosave: true
  has_many :websites, through: :website_members

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create
  has_secure_password

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
end
