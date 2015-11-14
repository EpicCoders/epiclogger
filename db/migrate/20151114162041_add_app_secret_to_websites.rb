class AddAppSecretToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :app_secret, :string
  end
end
