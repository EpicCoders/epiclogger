class OptimizeGroupedIssuesTable < ActiveRecord::Migration
  def change
    change_column :grouped_issues, :issue_logger, :string, limit: 64
    change_column :grouped_issues, :checksum, :string, limit: 32
    change_column :grouped_issues, :platform, :string, limit: 64
    add_index :grouped_issues, :issue_logger
    add_index :grouped_issues, :level
    add_index :grouped_issues, :last_seen
    add_index :grouped_issues, :first_seen
    add_index :grouped_issues, :status
    add_index :grouped_issues, :culprit
    add_index :grouped_issues, :times_seen
    add_index :grouped_issues, :website_id
    add_index :grouped_issues, :resolved_at
    add_index :grouped_issues, :active_at
    add_index :grouped_issues, [:website_id, :checksum], unique: true
  end
end
