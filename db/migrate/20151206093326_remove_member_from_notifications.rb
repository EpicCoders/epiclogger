class RemoveMemberFromNotifications < ActiveRecord::Migration
  def change
  	remove_column :notifications, :member_id
  end
end
