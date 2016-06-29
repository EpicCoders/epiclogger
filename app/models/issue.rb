class Issue < ActiveRecord::Base
  extend Enumerize
  has_many :messages
  belongs_to :subscriber
  belongs_to :group, class_name: 'GroupedIssue', foreign_key: 'group_id'
  delegate :website, to: :group
  accepts_nested_attributes_for :messages
  validates :message, presence: true, length: {minimum: 10}
  after_create :issue_created

  def error
    ErrorStore.find(self)
  end

  def get_interfaces(interface = nil)
    all_interaces = error._get_interfaces
    return all_interaces if interface.nil?
    all_interaces.find { |i| i.type == interface }
  end

  def get_headers(header = nil)
    all_headers = http_data(:headers)
    return all_headers if header.nil?
    all_headers.find { |h| h[header] }.try(:values).try(:first)
  end

  def breadcrumbs_stacktrace
    breadcrumbs = get_interfaces(:breadcrumbs)
    return false if breadcrumbs.blank?
    breadcrumbs._data[:values].flatten.reverse!
  end

  def http_data(key = nil)
    all_data = get_interfaces(:http)._data
    return '<no information>' if all_data.blank?
    return all_data if key.nil?
    all_data[key]
  end

  def stacktrace_frames
    #added a switch statement in case errors from different platforms will be saved differenty
    case platform
    when 'javascript'
      frames = get_interfaces(:stacktrace)._data[:frames]
      frames = [] if frames.blank?
    else
      frames = get_platform_frames
    end
    frames
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
    frames = get_platform_frames.first
    return frames if frame.nil?
    frames._data[frame]
  end

  def environment
    error.data[:environment]
  end

  def user_agent
    headers = error.data.try(:[], :interfaces).try(:[], :http).try(:[], :headers)
    unless headers.nil?
      headers.each do |hash|
        return UserAgent.parse(hash[:user_agent]) if hash[:user_agent]
      end
    end
    nil
  rescue => e
    "Could not parse data!"
  end

  def self.more_than_10_errors(member)
    GroupedIssueMailer.more_than_10_errors(member).deliver_later
  end

  def issue_created
    website.website_members.with_realtime.each do |member|
      GroupedIssueMailer.error_occurred(self, member).deliver_later
    end
  end
end