class GroupedIssue < ActiveRecord::Base
  extend Enumerize
  belongs_to :website
  enumerize :level, in: {:debug => 1, :error => 2, :fatal => 3, :info => 4, :warning => 5}, default: :error
  enumerize :issue_logger, in: {:javascript => 1, :php => 2}, default: :javascript
  enumerize :status, in: {:muted => 1, :resolved => 2, :unresolved => 3}

end
