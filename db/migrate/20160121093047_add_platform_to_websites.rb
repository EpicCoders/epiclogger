class AddPlatformToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :platform, :string
  end
end
