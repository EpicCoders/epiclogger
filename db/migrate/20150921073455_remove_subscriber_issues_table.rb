class RemoveSubscriberIssuesTable < ActiveRecord::Migration
  def change
    drop_table :subscriber_issues
  end
end
