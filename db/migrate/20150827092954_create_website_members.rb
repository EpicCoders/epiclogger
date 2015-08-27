class CreateWebsiteMembers < ActiveRecord::Migration
  def change
    create_table :website_members do |t|
    	t.integer :member_id
    	t.integer :website_id
    	t.integer :role
    end
    add_index :website_members, :member_id
    add_index :website_members, :website_id
  end
end
