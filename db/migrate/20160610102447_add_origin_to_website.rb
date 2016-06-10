class AddOriginToWebsite < ActiveRecord::Migration
  def change
  	add_column :websites, :origins, :text, default: '*'
  end
end
