class AddIndexOnSubscribersWebsiteAndIdentity < ActiveRecord::Migration
  def change
    remove_index :subscribers, column: [:email]
    add_index :subscribers, [:website_id, :email, :identity], unique:true
  end
end
