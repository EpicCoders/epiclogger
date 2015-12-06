class Website < ActiveRecord::Base
  belongs_to :member
  has_one :notification, through: :website_members, dependent: :destroy
  has_many :subscribers, dependent: :destroy
  has_many :grouped_issues, dependent: :destroy
  has_many :website_members, -> { uniq }, dependent: :destroy, autosave: true
  has_many :members, through: :website_members

  validates :title, :presence => true
  validates :domain, :presence => true

  attr_accessor :generate

  before_create :generate_api_keys
  before_update :generate_api_keys, if: -> { self.generate }

  protected
  def generate_api_keys
    self.app_key = loop do
      key = SecureRandom.hex(24)
      break key unless Website.exists?(app_key: key)
    end
    self.app_secret = loop do
      secret = SecureRandom.hex(6)
      break secret unless Website.exists?(app_secret: secret)
    end
  end

end

