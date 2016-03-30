class RenameTableMembersToUsers < ActiveRecord::Migration
  def change
    rename_column :members, :encrypted_password, :password_digest
    rename_table :members, :users
  end
end
