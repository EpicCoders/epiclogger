class AddColumnsToWebsiteMembers < ActiveRecord::Migration
  def change
    add_column :website_members, :realtime, :boolean, :default => false
    add_column :website_members, :frequent_event, :boolean, :default => false
    add_column :website_members, :daily_reporting, :boolean, :default => false
    add_column :website_members, :weekly_reporting, :boolean, :default => true
  end
end
