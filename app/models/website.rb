class Website < ActiveRecord::Base
  has_one :notification, dependent: :destroy
  has_many :subscribers, dependent: :destroy
  has_many :grouped_issues, dependent: :destroy
  has_many :website_members, -> { uniq }, dependent: :destroy, autosave: true
  has_many :members, through: :website_members

  validates :title, :presence => true
  validates :domain, :presence => true

  attr_accessor :generate

  before_create :generate_api_keys
  before_update :generate_api_keys, if: -> { self.generate }
  after_create :create_notification

  def create_notification
    Notification.create( website_id: self.id, new_event: true )
  end

  protected
  def generate_api_keys
    self.app_key = loop do
      key = SecureRandom.hex(24)
      break key unless Website.exists?(app_key: key)
    end
    self.app_id = loop do
      id = SecureRandom.hex(6)
      break id unless Website.exists?(app_key: id)
    end
  end

end

