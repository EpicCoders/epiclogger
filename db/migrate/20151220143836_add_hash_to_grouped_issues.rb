class AddHashToGroupedIssues < ActiveRecord::Migration
  def change
    add_column :grouped_issues, :checksum, :string
  end
end
