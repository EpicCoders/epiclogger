class RemoveInvitationTokenFromWebsiteMembers < ActiveRecord::Migration
  def change
  	remove_column :website_members, :invitation_token
  end
end
