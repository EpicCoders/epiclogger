class RemoveAppIdFromWebsites < ActiveRecord::Migration
  def change
    remove_column :websites, :app_id
  end
end
