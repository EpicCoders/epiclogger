class RemoveWebsiteIdFromIssues < ActiveRecord::Migration
  def change
    remove_column :issues, :website_id
  end
end
