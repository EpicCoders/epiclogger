class AddDefaultToOccurencesAndRemoveLast < ActiveRecord::Migration
  def change
    remove_column :issues, :last_occurrence
    change_column :issues, :occurrences, :integer, default: 0
  end
end
