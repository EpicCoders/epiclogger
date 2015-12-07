class RemoveNotificationIdFromWebsiteMembers < ActiveRecord::Migration
  def change
  	remove_column :website_members, :notification_id
  end
end
