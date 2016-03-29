class Member < ActiveRecord::Base
  # Include default devise modules.
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :trackable, :validatable,
  #        :confirmable
  # include DeviseTokenAuth::Concerns::User
  has_many :website_members, -> { uniq }, dependent: :destroy, autosave: true
  has_many :websites, through: :website_members

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  def is_owner_of?(website)
    website.website_members.with_role(:owner).where(website: website).map(&:member_id).include?(self.id)
  end
end
