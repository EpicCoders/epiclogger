class ChangeCountersDefaults < ActiveRecord::Migration
  def up
    change_column :grouped_issues, :times_seen, :integer, default: 1
  end

  def down
    change_column :grouped_issues, :times_seen, :integer, default: 0
  end
end
