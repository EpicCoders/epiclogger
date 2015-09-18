class AddSubscriberIdToIssues < ActiveRecord::Migration
  def change
  	add_reference :issues, :subscriber, index: true, foreign_key: true
  end
end
