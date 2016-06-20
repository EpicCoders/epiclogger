class AddForeignKeyRestrictionForIntegrations < ActiveRecord::Migration
  def change
    change_column :integrations, :website_id, :integer, foreign_key: { references: :websites, on_update: :restrict, on_delete: :cascade }
  end
end
