class ChangeLevelToStringInGroupedIssue < ActiveRecord::Migration
  def change
    change_column :grouped_issues, :level, :string, default: 'error'
  end
end
