class Website < ActiveRecord::Base
  has_many :subscribers, dependent: :destroy
  has_many :grouped_issues, dependent: :destroy
  has_many :website_members, -> { uniq }, autosave: true
  has_many :members, through: :website_members

  validates :title, presence: true
  validates :domain, presence: true
  validates_associated :website_members

  attr_accessor :generate

  before_create :generate_api_keys
  before_update :generate_api_keys, if: -> { generate }
  before_destroy :website_dependent

  def website_dependent
    website_members.each(&:delete)
  end

  def self.daily_report
    date = Time.now - 1.day
    Website.select("websites.id").joins(:grouped_issues).where("grouped_issues.updated_at > ?", date).uniq.each do |website|
      UserMailer.notify_daily(website.id).deliver_now
    end
  end

  protected

  def generate_api_keys
    self.app_key = loop do
      key = SecureRandom.hex(24)
      break key unless Website.exists?(app_key: key)
    end
    self.app_secret = loop do
      secret = SecureRandom.hex(6)
      break id unless Website.exists?(app_secret: secret)
    end
  end
end
