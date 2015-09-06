class CreateGroupedIssues < ActiveRecord::Migration
  def change
    create_table :grouped_issues do |t|
      t.integer :website_id
      t.integer :logger
      t.integer :level
      t.text :message
      t.string :view
      t.integer :status
      t.integer :times_seen
      t.datetime :first_seen
      t.datetime :last_seen
      t.text :data
      t.integer :score
      t.datetime :time_spent_total
      t.integer :time_spent_count
      t.datetime :resolved_at
      t.datetime :active_at
      t.string :platform

      t.timestamps null: false
    end
  end
end
