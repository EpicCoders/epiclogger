class Issue < ActiveRecord::Base
  extend Enumerize
  has_many :messages
  belongs_to :subscriber
  belongs_to :website
  belongs_to :group, class_name: 'GroupedIssue', foreign_key: 'group_id'
  accepts_nested_attributes_for :messages
  validates :message, presence: true, length: {minimum: 10}

  def error
    ErrorStore.find(self)
  end

  def get_interfaces(interface = nil)
    all_interaces = error._get_interfaces
    return all_interaces if interface.nil?
    all_interaces.find { |i| i.type == interface }
  end

  def stacktrace_frames
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
end
