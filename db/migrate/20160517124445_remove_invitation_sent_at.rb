class RemoveInvitationSentAt < ActiveRecord::Migration
  def change
  	remove_column :website_members, :invitation_sent_at
  end
end
