class AddSlugToGroupedIssues < ActiveRecord::Migration
  def change
    remove_column :grouped_issues, :uuid, :string
    add_column :grouped_issues, :slug, :string
    add_index :grouped_issues, :slug, unique: true
  end
end
