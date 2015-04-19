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

ActiveRecord::Schema.define(version: 20150418192644) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "errors", force: :cascade do |t|
    t.text     "description", null: false
    t.integer  "user_id",     null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "errors", ["user_id"], name: "index_errors_on_user_id", using: :btree

  create_table "members", force: :cascade do |t|
    t.string   "email",      null: false
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "members", ["email"], name: "index_members_on_email", unique: true, using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.text     "content",    null: false
    t.integer  "error_id",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "messages", ["error_id"], name: "index_messages_on_error_id", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "email",      null: false
    t.integer  "website_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  create_table "websites", force: :cascade do |t|
    t.string   "title",      null: false
    t.string   "domain",     null: false
    t.integer  "member_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "websites", ["member_id"], name: "index_websites_on_member_id", using: :btree

end
