class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :word, null: false
      t.references :game_status, index: true, foreign_key: true, default: 0
      t.integer :lives, null: false

      t.timestamps null: false
    end
  end
end
