class AddColumnToWebsiteMember < ActiveRecord::Migration
  def change
  	add_reference :website_members, :notification, index: true, foreign_key: true
  end
end
