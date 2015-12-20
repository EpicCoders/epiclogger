class AddDetailsToGroupedIssues < ActiveRecord::Migration
  def change
    add_column :grouped_issues, :culprit, :string
  end
end
