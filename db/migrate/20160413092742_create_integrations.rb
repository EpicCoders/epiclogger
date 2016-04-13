class CreateIntegrations < ActiveRecord::Migration
  def change
    create_table :integrations do |t|
      t.belongs_to :website, index: true, foreign_key: true
      t.string :provider, null: false
      t.text :configuration
      t.string :name, null: false
      t.boolean :disabled, default: false
      t.text :error

      t.timestamps null: false
    end
  end
end
