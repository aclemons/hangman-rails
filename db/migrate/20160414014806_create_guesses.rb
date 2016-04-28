class CreateGuesses < ActiveRecord::Migration
  def change
    create_table :guesses do |t|
      t.string :letter, null: false
      t.references :game, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :guesses, [:letter, :game_id], unique: true
  end
end
