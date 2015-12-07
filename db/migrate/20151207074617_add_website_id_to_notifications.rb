class AddWebsiteIdToNotifications < ActiveRecord::Migration
  def change
  	add_reference :notifications, :website, index: true, foreign_key: true
  	rename_column :notifications, :daily_reports, :daily
  	rename_column :notifications, :realtime_error, :realtime
  	rename_column :notifications, :when_event, :new_event
  	rename_column :notifications, :more_than_10, :frequent_event
  end
end
