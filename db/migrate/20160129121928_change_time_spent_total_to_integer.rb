class ChangeTimeSpentTotalToInteger < ActiveRecord::Migration
  def change
    remove_column :grouped_issues, :time_spent_total
    add_column :grouped_issues, :time_spent_total, :integer, default: 0
    change_column :grouped_issues, :time_spent_count, :integer, default: 0
    change_column :grouped_issues, :times_seen, :integer, default: 0
  end
end
