class AddEnvironmentToGroupedIssues < ActiveRecord::Migration
  def change
    add_column :grouped_issues, :environment, :string
  end
end
