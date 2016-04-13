class GroupedIssue < ActiveRecord::Base
  extend Enumerize
  belongs_to :website
  belongs_to :release
  has_many :subscribers, -> { uniq }, through: :issues, foreign_key: 'group_id'
  has_many :issues, foreign_key: 'group_id', dependent: :destroy
  enumerize :level, in: [:debug, :error, :fatal, :info, :warning], default: :error
  # enumerize :issue_logger, in: { javascript: 1, php: 2 }, default: :javascript
  enumerize :status, in: { muted: 1, resolved: 2, unresolved: 3 }, default: :unresolved, predicates: true
  after_create :group_created

  before_save :check_fields

  def group_created
    # UserMailer.event_occurred(self.website_id, self.id).deliver_now
  end

  def first_issue
    issues.first
  end

  def environment
    first_issue.environment
  end

  def users_affected
    subscribers.count
  end

  def chart_data
    data = []
    issues = self.issues.where('created_at >= ? AND created_at <= ?', Date.today - 3.months, Date.today.end_of_day)
    (Date.today - 3.months..Date.today).map(&:to_date).each do |date|
      times = issues.select { |issue| issue.created_at.to_date == date }
      data.push({value: times.size, date: date.strftime('%Y-%m-%d')})
    end
    data
  end

  private

  def check_fields
    self.resolved_at = Time.now.utc if status_changed? && resolved?
    self.last_seen = Time.now.utc if last_seen.blank?
    self.first_seen = last_seen if first_seen.blank?
    self.active_at = first_seen if active_at.blank?
    # We limit what we store for the message body
    self.message = message.truncate(255, separator: '') unless message.blank?
  end

  # define the above status hash as variables
  status.values.each do |s|
    class_eval <<-EOV, __FILE__, __LINE__
      #{s.upcase} = GroupedIssue.status.find_value(s.to_sym).value
    EOV
  end
end
