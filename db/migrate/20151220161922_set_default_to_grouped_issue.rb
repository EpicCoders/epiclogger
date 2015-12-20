class SetDefaultToGroupedIssue < ActiveRecord::Migration
  def change
    change_column :grouped_issues, :times_seen, :integer, default: 1
    change_column :grouped_issues, :status, :integer, default: 3
  end
end
