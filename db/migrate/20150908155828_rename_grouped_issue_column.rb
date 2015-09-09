class RenameGroupedIssueColumn < ActiveRecord::Migration
  def change
  	rename_column :grouped_issues, :logger, :issue_logger
  end
end
