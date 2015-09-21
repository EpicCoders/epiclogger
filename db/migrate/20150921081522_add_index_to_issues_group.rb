class AddIndexToIssuesGroup < ActiveRecord::Migration
  def change
    add_index :issues, :group_id
  end
end
