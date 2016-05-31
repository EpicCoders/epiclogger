class Issue < ActiveRecord::Base
  extend Enumerize
  has_many :messages
  belongs_to :subscriber
  belongs_to :website
  belongs_to :group, class_name: 'GroupedIssue', foreign_key: 'group_id'
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

  def stacktrace_frames
    #added a switch statement in case errors from different platforms will be saved differenty
    case platform
    when 'javascript'
      frames = get_interfaces(:stacktrace)._data[:frames]
      frames = 'Missing stacktrace' if frames.blank?
    else
      frames = get_platform_frames
    end
    frames
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

  def environment
    error.data[:environment]
  end

  def user_agent
    headers = JSON.parse(data).try(:[], "interfaces").try(:[], "http").try(:[], "headers")
    unless headers.nil?
      headers.each do |hash|
        return UserAgent.parse(hash["user_agent"]) if hash["user_agent"]
      end
    end
    nil
  rescue => e
    "Could not parse data!"
  end

  def issue_created
    counter = website.issues.where('issues.created_at > ?', Time.now - 1.hour).count
    if counter >= 10
      UserMailer.more_than_10_errors(self).deliver_later
    else
      UserMailer.error_occurred(self).deliver_later
    end
  end
end
