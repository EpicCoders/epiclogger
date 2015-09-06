class UpdateIssuesTable < ActiveRecord::Migration
  def change
    change_table(:issues) do |t|
      t.integer :group_id, :after => :id
      t.string :platform, :after => :description
      t.text :data, :after => :platform
      t.integer :time_spent
    end

    remove_column :issues, :occurrences, :integer
    remove_column :issues, :status, :integer
  end
end
