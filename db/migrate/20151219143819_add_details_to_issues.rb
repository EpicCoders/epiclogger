class AddDetailsToIssues < ActiveRecord::Migration
  def change
    add_reference :issues, :website, index: true, foreign_key: true
    add_column :issues, :event_id, :string
    add_column :issues, :datetime, :datetime
    add_column :issues, :message, :text
    remove_column :issues, :description
  end
end
