class AddWebsiteToRelease < ActiveRecord::Migration
  def change
  	add_reference :releases, :website, index: true, foreign_key: true
  end
end
