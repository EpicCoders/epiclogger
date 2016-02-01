class RemoveViewColumnFromGroupedIssues < ActiveRecord::Migration
  def change
    remove_column :grouped_issues, :view
  end
end
