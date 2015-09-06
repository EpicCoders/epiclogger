class GroupedIssue < ActiveRecord::Base

  enumerize :level, in: {:debug => 1, :info => 2, :warning => 3, :error => 4, :fatal => 5}, default: :error
  enumerize :logger, in: {:javascript => 1, :php => 2}, default: :javascript

end