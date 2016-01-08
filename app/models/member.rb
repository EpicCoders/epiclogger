class Member < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable
  include DeviseTokenAuth::Concerns::User
  has_many :website_members, -> { uniq }, dependent: :destroy, autosave: true
  has_many :websites, through: :website_members

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  #used in controllers to check if a member owns a website
  def is_owner_of?(website)
    WebsiteMember.with_role(:owner).where(website: website).map(&:member_id).include?(self.id)
  end

end
