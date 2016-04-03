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

  def get_interfaces
    error._get_interfaces
  end

  def stacktrace_frames
    exception = get_interfaces.first
    return 'Missing stacktrace' if exception.blank?
    get_interfaces.first._data[:values].first._data[:stacktrace]._data[:frames].reverse!
  end
end
