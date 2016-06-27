class AddUniqueToUuidIndex < ActiveRecord::Migration
  def change
    remove_index :grouped_issues, :uuid
    add_index :grouped_issues, :uuid, unique: true
  end
end
