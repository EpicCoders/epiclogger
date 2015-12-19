class AddDetailsToSubscribers < ActiveRecord::Migration
  def change
    add_column :subscribers, :identity, :string
    add_column :subscribers, :username, :string
    add_column :subscribers, :ip_address, :string
  end
end
