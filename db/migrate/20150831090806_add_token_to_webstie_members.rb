class AddTokenToWebstieMembers < ActiveRecord::Migration
  def change
    add_column :website_members, :invitation_token, :string
    add_column :website_members, :invitation_sent_at, :string
  end
end
