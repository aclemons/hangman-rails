# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160414014806) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "game_statuses", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "game_statuses", ["name"], name: "index_game_statuses_on_name", unique: true, using: :btree

  create_table "games", force: :cascade do |t|
    t.string   "word",                       null: false
    t.integer  "game_status_id", default: 0
    t.integer  "lives",                      null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "games", ["game_status_id"], name: "index_games_on_game_status_id", using: :btree

  create_table "guesses", force: :cascade do |t|
    t.string   "letter",     null: false
    t.integer  "game_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "guesses", ["game_id"], name: "index_guesses_on_game_id", using: :btree
  add_index "guesses", ["letter", "game_id"], name: "index_guesses_on_letter_and_game_id", unique: true, using: :btree

  add_foreign_key "games", "game_statuses"
  add_foreign_key "guesses", "games"
end
