class AddReleaseToGroupedIssue < ActiveRecord::Migration
  def change
  	add_reference :grouped_issues, :release, index: true, foreign_key: true
  end
end
