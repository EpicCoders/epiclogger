class GroupedIssue < ActiveRecord::Base
  extend Enumerize
  extend FriendlyId
  belongs_to :website
  belongs_to :release
  has_many :subscribers, -> { uniq }, through: :issues, foreign_key: 'group_id'
  has_many :issues, foreign_key: 'group_id', dependent: :destroy
  has_many :messages, through: :issues
  enumerize :level, in: [:debug, :error, :fatal, :info, :warning], default: :error
  # enumerize :issue_logger, in: { javascript: 1, php: 2 }, default: :javascript
  enumerize :status, in: { muted: 1, resolved: 2, unresolved: 3 }, default: :unresolved, predicates: true, scope: true
  friendly_id :message, use: :slugged
  before_save :check_fields

  def users_affected
    subscribers.count
  end

  def aggregations (attribute)
    data = []
    self.issues.each do |issue|
      value = issue.public_send(attribute)
      unless value.nil?
        found = data.index { |x| x[attribute] == value }
        if found
          data[found]["count"] += 1
        else
          data.push( { attribute => value, "count" => 1, "created_at" => issue.created_at, "updated_at" => issue.updated_at } )
        end
      end
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
