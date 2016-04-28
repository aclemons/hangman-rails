class CreateGameStatuses < ActiveRecord::Migration

  def change
    create_table(:game_statuses, :id => false) do |t|
      t.integer :id, null: false
      t.string  :name, null: false

      t.timestamps null: false
    end
    add_index :game_statuses, :name, unique: true

    # jumping through hoops to make rails generate a table without auto-increment id
    reversible do |dir|
      dir.up do
        if ActiveRecord::Base.connection.instance_of? ActiveRecord::ConnectionAdapters::SQLite3Adapter
          execute "CREATE UNIQUE INDEX index_game_statuses_on_id ON game_statuses(id);"
        else
          execute "ALTER TABLE game_statuses ADD PRIMARY KEY (id);"
        end
      end
      dir.down do
        if ActiveRecord::Base.connection.instance_of? ActiveRecord::ConnectionAdapters::SQLite3Adapter
          execute "DROP INDEX index_game_statuses_on_id;"
        else
          execute "ALTER TABLE game_statuses DROP PRIMARY KEY (id);"
        end
      end
    end

    reversible do |dir|
      dir.up do
        # do not reuse the GameStatus class since it may change
        execute "INSERT INTO game_statuses VALUES (0, 'New', current_timestamp, current_timestamp);"
        execute "INSERT INTO game_statuses VALUES (1, 'In Progress', current_timestamp, current_timestamp);"
        execute "INSERT INTO game_statuses VALUES (2, 'Lost', current_timestamp, current_timestamp);"
        execute "INSERT INTO game_statuses VALUES (3, 'Won', current_timestamp, current_timestamp);"
      end
      dir.down do
        execute "DELETE FROM game_statuses WHERE id IN (0, 1, 2, 3);"
      end
    end
  end
end
