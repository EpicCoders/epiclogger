class Member < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable
  include DeviseTokenAuth::Concerns::User
  has_many :website_members, -> { uniq }, dependent: :destroy, autosave: true
  has_many :websites, through: :website_members
  has_one :notification, dependent: :destroy, autosave: true

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  attr_accessor :confirm_success_url

  before_create :skip_confirmation!
  after_create :send_confirmation_email

  def send_confirmation_email
    self.send_confirmation_instructions
  end
end
