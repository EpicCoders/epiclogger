class RemoveDataFromGroupedIssues < ActiveRecord::Migration
  def change
    remove_column :grouped_issues, :data
  end
end
