class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
    	t.boolean :daily_reports, default: false
      t.boolean :realtime_error, default: false
      t.boolean :when_event, default: false
      t.integer :member_id, null: false

      t.timestamps null: false
    end
    add_index :notifications, :member_id
  end
end
