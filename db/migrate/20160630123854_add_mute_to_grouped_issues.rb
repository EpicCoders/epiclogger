class AddMuteToGroupedIssues < ActiveRecord::Migration
  def change
    add_column :grouped_issues, :muted, :boolean, :default => false
  end
end