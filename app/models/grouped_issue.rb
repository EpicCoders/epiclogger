class GroupedIssue < ActiveRecord::Base
  extend Enumerize
  belongs_to :website
  has_many :subscribers, through: :issues, foreign_key: 'group_id'
  has_many :issues, foreign_key: 'group_id', dependent: :destroy
  enumerize :level, in: {:debug => 1, :error => 2, :fatal => 3, :info => 4, :warning => 5}, default: :error
  enumerize :issue_logger, in: {:javascript => 1, :php => 2}, default: :javascript
  enumerize :status, in: {:muted => 1, :resolved => 2, :unresolved => 3}, default: :unresolved
  after_create :group_created

  def group_created
    # UserMailer.event_occurred(self.website_id, self.id).deliver_now
  end

  def error
    ErrorStore.find(self)
  end

  def is_resolved?
    status.resolved?
  end

end
