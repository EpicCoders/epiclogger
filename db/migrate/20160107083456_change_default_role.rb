class ChangeDefaultRole < ActiveRecord::Migration
  def change
  	change_column :website_members, :role, :integer, :default => 1
  end
end
