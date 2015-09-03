class RemoveMemberIdFromWebsites < ActiveRecord::Migration
  def change
    remove_column :websites, :member_id
  end
end
