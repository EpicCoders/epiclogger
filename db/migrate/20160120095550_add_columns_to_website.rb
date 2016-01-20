class AddColumnsToWebsite < ActiveRecord::Migration
  def change
  	add_column :websites, :new_event, :boolean, :default => true
  	add_column :websites, :frequent_event, :boolean, :default => false
  	add_column :websites, :daily, :boolean, :default => false
  	add_column :websites, :realtime, :boolean, :default => false
  end
end
