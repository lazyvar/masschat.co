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

ActiveRecord::Schema.define(version: 2018_12_31_165304) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "masschat_users", force: :cascade do |t|
    t.string "username", null: false
    t.string "phonenumber", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phonenumber"], name: "index_masschat_users_on_phonenumber", unique: true
    t.index ["username"], name: "index_masschat_users_on_username", unique: true
  end

  create_table "posts", force: :cascade do |t|
    t.string "url"
    t.string "query"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "masschat_user_id", null: false
    t.string "title"
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "masschat_user_id", null: false
    t.boolean "up", null: false
    t.bigint "post_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["masschat_user_id"], name: "index_votes_on_masschat_user_id"
    t.index ["post_id"], name: "index_votes_on_post_id"
  end

end
