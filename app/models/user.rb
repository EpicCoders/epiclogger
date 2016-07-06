class User < ActiveRecord::Base
  # include the TokenGenerator extension
  extend Enumerize
  include TokenGenerator
  has_many :website_members, -> { distinct }, dependent: :destroy, autosave: true
  has_many :websites, through: :website_members
  has_many :invites, foreign_key: :invited_by_id

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, confirmation: true, length: { minimum: 6 }, on: :create, if: :default_provider?
  has_secure_password(validations: false)
  enumerize :role, in: { admin: 1, user: 2 }, default: :user, scope: true, predicates: true

  before_create { generate_token(:uid) if default_provider? }

  def is_owner_of?(website)
    website.website_members.with_role(:owner).pluck(:user_id).include?(id)
  end

  def is_member_of?(website)
    website.website_members.pluck(:user_id).include?(id)
  end

  def default_website
    websites.try(:first)
  end

  def default_provider?
    provider == 'email'
  end

  def send_reset_password
    generate_token :reset_password_token
    self.reset_password_sent_at = Time.zone.now
    save!
    UserMailer.reset_password(self).deliver_later
  end

  def avatar_url(size = 40)
    gravatar = Digest::MD5.hexdigest(email).downcase
    "http://gravatar.com/avatar/#{gravatar}.png?s=#{size}"
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      user.name = auth['info']['name'] || auth['info']['nickname']
      user.email = auth['info']['email']
      user.password = SecureRandom.urlsafe_base64(16) unless auth['provider'] == 'email'
    end
  end

  def confirmed?
    !confirmed_at.blank?
  end

  def confirm
    update_attributes(confirmation_token: nil, confirmed_at: Time.now.utc)
  end

  def send_confirmation
    generate_token(:confirmation_token)
    self.confirmation_sent_at = Time.now
    save!
    UserMailer.email_confirmation(self).deliver_later
  end
end
