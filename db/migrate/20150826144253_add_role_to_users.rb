class AddRoleToUsers < ActiveRecord::Migration
  def change
  	add_column :subscribers, :role, :integer, :default => 2
  end
end
