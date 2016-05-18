class RenameInvitesColumn < ActiveRecord::Migration
  def change
  	rename_column :invites, :user_id, :invited_by_id
  end
end
