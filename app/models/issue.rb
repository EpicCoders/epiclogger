class Issue < ActiveRecord::Base
  include ErrorStore::Utils
  has_many :messages
  belongs_to :subscriber
  belongs_to :group, class_name: 'GroupedIssue', foreign_key: 'group_id'
  delegate :website, to: :group
  accepts_nested_attributes_for :messages
  validates :message, presence: true
  after_create :issue_created
  after_commit :refresh_aggregates

  def error
    ErrorStore.find(self)
  end

  def data=(data)
    super(encode_and_compress(data))
  end

  def data
    decode_and_decompress(super)
  end

  def refresh_aggregates
    AggregatesWorker.perform_async(self.id)
  end

  def get_interfaces(interface = nil)
    all_interaces = error._get_interfaces
    return all_interaces if interface.nil?
    all_interaces.find { |i| i.type == interface }
  end

  def get_headers(header = nil)
    all_headers = http_data(:headers)
    return all_headers if header.nil? || !all_headers
    all_headers.find { |h| h[header] }.try(:values).try(:first)
  end

  def breadcrumbs_stacktrace
    breadcrumbs = get_interfaces(:breadcrumbs)
    return false if breadcrumbs.blank?
    breadcrumbs._data[:values].flatten.reverse!
  end

  def http_data(key = nil)
    all_data = get_interfaces(:http).try(:_data)
    return nil if all_data.blank?
    return all_data if key.nil?
    all_data[key]
  end

  def get_platform_frames
    exception = get_interfaces(:exception)
    return false if exception.blank?
    frames = []
    exception._data[:values].each do |value|
      next unless value._data[:stacktrace]
      frames << value._data[:stacktrace]._data[:frames] || []
    end
    frames.flatten.reverse!
  end

  def get_frames(frame = nil)
    frames = get_platform_frames.try(:first)
    return frames if frame.nil?
    frames._data[frame]
  end

  def environment
    error.data[:environment]
  end

  def version
    modules = error.data[:modules]
    unless modules.nil?
      case self.platform
      when 'ruby'
        key = 'rails'
      end
      "#{key.capitalize}/#{modules[key.to_sym]}" if defined? key
    end
  rescue => e
    Raven.capture_exception(e)
    'Could not parse data!'
  end

  def notifier_remote_address
    http_data(:env).try(:[], :REMOTE_ADDR)
  rescue => e
    Raven.capture_exception(e)
    'Could not parse data!'
  end

  def server_hostnames
    error.data.try(:[], :server_name)
  rescue => e
    Raven.capture_exception(e)
    'Could not parse data!'
  end

  def file
    get_frames.try(:get_culprit_string, with_lineno: get_frames.try(:_data).try(:[], :lineno).present?)
  rescue => e
    Raven.capture_exception(e)
    'Could not parse data!'
  end

  def url
    url_string = http_data(:url)
  rescue => e
    Raven.capture_exception(e)
    'Could not parse data!'
  end

  def browser_platform
    user_agent = get_headers(:user_agent)
    return UserAgent.parse(user_agent).platform unless user_agent.nil?
  rescue => e
    Raven.capture_exception(e)
    'Could not parse data!'
  end

  def browser
    user_agent = get_headers(:user_agent)
    return UserAgent.parse(user_agent).browser unless user_agent.nil?
  rescue => e
    Raven.capture_exception(e)
    'Could not parse data!'
  end

  def user
    user_data = get_interfaces(:user)
    return "##{user_data._data[:id]} #{user_data._data[:user_name]} #{user_data._data[:email]}" unless user_data.nil?
  rescue => e
    Raven.capture_exception(e)
    'Could not parse data!'
  end

  def self.more_than_10_errors(member)
    GroupedIssueMailer.more_than_10_errors(member).deliver_later
  end

  def issue_created
    website.website_members.with_realtime.each do |member|
      GroupedIssueMailer.error_occurred(self, member).deliver_later
    end
  end

  class AggregatesWorker
    include Sidekiq::Worker
    def perform(issue_id)
      record = Issue.find(issue_id)
      ErrorStore::Aggregates.new(record).handle_aggregates
    end
  end
end
