class CreateAggregations < ActiveRecord::Migration
  def change
    create_table :aggregates do |t|
      t.integer :group_id
      t.string :type
      t.jsonb :value, default: {}

      t.timestamps null: false
    end
  end
end
