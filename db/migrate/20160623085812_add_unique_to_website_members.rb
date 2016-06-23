class AddUniqueToWebsiteMembers < ActiveRecord::Migration
  def change
    add_index :website_members, [:user_id, :website_id], unique: true
  end
end
