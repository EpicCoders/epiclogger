class RemoveNotificationsFromWebsites < ActiveRecord::Migration
  def change
    remove_column :websites, :realtime
    remove_column :websites, :frequent_event
    remove_column :websites, :daily
    remove_column :websites, :new_event
  end
end
