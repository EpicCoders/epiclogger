class AddAppIdAndAppKeyToWebsites < ActiveRecord::Migration
  def change
  	add_column :websites, :app_id, :integer
  	add_column :websites, :app_key, :string
  end
end
