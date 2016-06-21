class AddForeignKeysToTables < ActiveRecord::Migration
  def change
    # grouped issues table
    change_column :grouped_issues, :website_id, :integer, foreign_key: { references: :websites, on_update: :restrict, on_delete: :cascade }
    change_column :grouped_issues, :release_id, :integer, foreign_key: { references: :releases, on_update: :restrict, on_delete: :cascade }

    # invites table
    change_column :invites, :website_id, :integer, foreign_key: { references: :websites, on_update: :restrict, on_delete: :cascade }
    change_column :invites, :invited_by_id, :integer, foreign_key: { references: :users, on_update: :restrict, on_delete: :cascade }

    # issues
    change_column :issues, :group_id, :integer, foreign_key: { references: :grouped_issues, on_update: :restrict, on_delete: :cascade }
    change_column :issues, :subscriber_id, :integer, foreign_key: { references: :subscribers, on_update: :restrict, on_delete: :cascade }

    # messages
    change_column :messages, :issue_id, :integer, foreign_key: { references: :issues, on_update: :restrict, on_delete: :cascade }

    # releases
    change_column :releases, :website_id, :integer, foreign_key: { references: :websites, on_update: :restrict, on_delete: :cascade }

    # subscribers
    change_column :subscribers, :website_id, :integer, foreign_key: { references: :websites, on_update: :restrict, on_delete: :cascade }

    # website_members
    change_column :website_members, :website_id, :integer, foreign_key: { references: :websites, on_update: :restrict, on_delete: :cascade }
    change_column :website_members, :user_id, :integer, foreign_key: { references: :users, on_update: :restrict, on_delete: :cascade }
  end
end
