class OptimizeIssuesTable < ActiveRecord::Migration
  def change
    remove_column :issues, :page_title
    add_index :issues, :datetime
  end
end
