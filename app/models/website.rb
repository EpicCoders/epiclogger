class Website < ActiveRecord::Base
  include ModelUtils::URIField
  # include the TokenGenerator extension
  include TokenGenerator
  has_many :subscribers, dependent: :destroy
  has_many :issues, through: :grouped_issues
  has_many :releases, dependent: :destroy
  has_many :grouped_issues, dependent: :destroy
  has_many :website_members, -> { uniq }, autosave: true
  has_many :users, through: :website_members
  has_many :invites, dependent: :destroy

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

  # match a release
  def check_release(version)
    last_release = releases.last
    unless version.nil?
      release = releases.create_with(website_id: id).find_or_create_by(version: version)
      unless last_release.nil? || last_release.version == release.version
        last_release.grouped_issues.update_all(status: GroupedIssue::RESOLVED, resolved_at: Time.now.utc)
      end
    end
    release = last_release if version.nil?

    return release
  end

  def self.daily_report
    date = Time.now - 1.day
    Website.joins(:grouped_issues).where('grouped_issues.updated_at > ?', date).uniq.each do |website|
      GroupedIssueMailer.notify_daily(website).deliver_later
    end
  end

  def valid_origin?(value)
    return true if origins.include?('*') # return true if we allow all
    return false if origins.blank? # no origins to check against
    return false if value.blank?
    value = value.downcase
    origins.include?(value)
    # TODO add here option to define origins with path *
  end

  protected

  def generate_api_keys
    generate_token(:app_key)
    generate_token(:app_secret)
  end
end
