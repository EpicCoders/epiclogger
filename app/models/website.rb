class Website < ActiveRecord::Base
  include ModelUtils::URIField
  has_many :subscribers, dependent: :destroy
  has_many :releases, dependent: :destroy
  has_many :grouped_issues, dependent: :destroy
  has_many :website_members, -> { uniq }, autosave: true
  has_many :users, through: :website_members

  validates :title, presence: true
  validates :domain, presence: true
  ensure_valid_protocol :domain
  validates_associated :website_members
  validate :unique_domain, on: :create

  attr_accessor :generate

  before_create :generate_api_keys
  before_update :generate_api_keys, if: -> { generate }
  before_destroy :website_dependent

  def website_dependent
    website_members.each(&:delete)
  end

  def unique_domain
    domain = URI.parse(self.domain)
    website_cases = ["http://#{domain.host}", "https://#{domain.host}", "ftp://#{domain.host}", self.domain]
    return true unless Website.exists?(domain: website_cases)
    errors.add :website, 'This website already exists for you'
    false
  end

  #match a release
  def check_release(slug)
    last_release = self.releases.last
    unless slug.nil?
      release = self.releases.create_with(website_id: self.id).find_or_create_by(version: slug)
      unless last_release.nil? || last_release.version == release.version
        last_release.grouped_issues.update_all( status: GroupedIssue.status.find_value('resolved').value )
      end
    end
    release = last_release if slug.nil?

    return release
  end

  def self.daily_report
    date = Time.now - 1.day
    Website.select("websites.id").joins(:grouped_issues).where('grouped_issues.updated_at > ?', date).uniq.each do |website|
      UserMailer.notify_daily(website.id).deliver_now
    end
  end

  protected

  def generate_api_keys
    self.app_key = loop do
      key = SecureRandom.hex(16)
      break key unless Website.exists?(app_key: key)
    end
    self.app_secret = loop do
      secret = SecureRandom.hex(16)
      break secret unless Website.exists?(app_secret: secret)
    end
  end
end
