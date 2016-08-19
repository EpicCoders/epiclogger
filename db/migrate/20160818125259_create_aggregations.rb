class CreateAggregations < ActiveRecord::Migration
  def change
    create_table :aggregates do |t|
      t.belongs_to :grouped_issue, index: true, foreign_key: { references: :grouped_issues, on_update: :restrict, on_delete: :cascade }
      t.string :agg_type
      t.jsonb :value, default: {}

      t.timestamps null: false
    end
  end
end
