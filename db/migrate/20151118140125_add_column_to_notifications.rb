class AddColumnToNotifications < ActiveRecord::Migration
  def change
  	add_column :notifications, :more_than_10, :boolean, :default => false
  end
end
