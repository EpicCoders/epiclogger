class ChangeFormatInConfigurations < ActiveRecord::Migration
  def up
    remove_column :integrations, :configuration
    execute "CREATE EXTENSION hstore"
    add_column :integrations, :configuration, :hstore
    execute "CREATE INDEX configuration_gin ON integrations USING GIN(configuration)"
  end

  def down
    remove_column :integrations, :configuration
    execute "DROP EXTENSION hstore"
    add_column :integrations, :configuration, :text
    execute "DROP INDEX configuration_data"
  end
end
