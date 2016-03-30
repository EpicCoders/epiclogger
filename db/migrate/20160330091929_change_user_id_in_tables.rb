class ChangeUserIdInTables < ActiveRecord::Migration
  def change
    rename_column :website_members, :member_id, :user_id
  end
end
