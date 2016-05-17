class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.integer :user_id
      t.integer :website_id
      t.string :email
      t.string :token
      t.datetime :accepted_at

      t.timestamps null: false
    end
  end
end
