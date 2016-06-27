class AddUuidToGroupedIssues < ActiveRecord::Migration
  def change
    add_column :grouped_issues, :uuid, :string
    add_index :grouped_issues, :uuid
  end
end
