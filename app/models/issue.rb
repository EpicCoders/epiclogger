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
    all_headers = get_interfaces(:http)._data[:headers]
    return all_headers if header.nil?
    all_headers.find { |h| h[header] }.try(:values).try(:first)
  end

  def breadcrumbs_stacktrace
    breadcrumbs = get_interfaces(:breadcrumbs)
    return 'Missing breadcrumbs' if breadcrumbs.blank?
    breadcrumbs._data[:values].flatten.reverse!
  end

  def get_platform_frames
    exception = get_interfaces(:exception)
    return 'Missing stacktrace' if exception.blank?
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

  def issue_created
    if website.issues.where('issues.created_at > ?', Time.now - 1.hour).count > 10
      GroupedIssueMailer.more_than_10_errors(website).deliver_later
    else
      GroupedIssueMailer.error_occurred(self).deliver_later
    end
  end
end