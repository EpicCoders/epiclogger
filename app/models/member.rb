class Member < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable
  include DeviseTokenAuth::Concerns::User
  has_many :website_members, -> { uniq }, dependent: :destroy, autosave: true, inverse_of: :website
  has_many :websites, through: :website_members, inverse_of: :member

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  attr_accessor :confirm_success_url
end
