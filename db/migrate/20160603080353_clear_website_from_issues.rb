class ClearWebsiteFromIssues < ActiveRecord::Migration
  def change
    remove_column :issues, :website_id
    add_foreign_key :issues, :grouped_issues, column: :group_id, on_update: :restrict, on_delete: :cascade
  end
end
