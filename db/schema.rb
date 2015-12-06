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

ActiveRecord::Schema.define(version: 20151206093326) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "grouped_issues", force: :cascade do |t|
    t.integer  "website_id"
    t.integer  "issue_logger"
    t.integer  "level"
    t.text     "message"
    t.string   "view"
    t.integer  "status"
    t.integer  "times_seen"
    t.datetime "first_seen"
    t.datetime "last_seen"
    t.text     "data"
    t.integer  "score"
    t.datetime "time_spent_total"
    t.integer  "time_spent_count"
    t.datetime "resolved_at"
    t.datetime "active_at"
    t.string   "platform"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "issues", force: :cascade do |t|
    t.text     "description",   null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "page_title"
    t.integer  "group_id"
    t.string   "platform"
    t.text     "data"
    t.integer  "time_spent"
    t.integer  "subscriber_id"
  end

  add_index "issues", ["group_id"], name: "index_issues_on_group_id", using: :btree
  add_index "issues", ["subscriber_id"], name: "index_issues_on_subscriber_id", using: :btree

  create_table "members", force: :cascade do |t|
    t.string   "email",                               null: false
    t.string   "name",                                null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "provider",                            null: false
    t.string   "uid",                    default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "nickname"
    t.string   "image"
    t.text     "tokens"
  end

  add_index "members", ["email"], name: "index_members_on_email", unique: true, using: :btree
  add_index "members", ["reset_password_token"], name: "index_members_on_reset_password_token", unique: true, using: :btree
  add_index "members", ["uid", "provider"], name: "index_members_on_uid_and_provider", unique: true, using: :btree

  create_table "messages", force: :cascade do |t|
    t.text     "content",    null: false
    t.integer  "issue_id",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "messages", ["issue_id"], name: "index_messages_on_issue_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.boolean  "daily_reports",  default: false
    t.boolean  "realtime_error", default: false
    t.boolean  "when_event",     default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "more_than_10",   default: false
  end

  create_table "subscribers", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "email",      null: false
    t.integer  "website_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "subscribers", ["email"], name: "index_subscribers_on_email", unique: true, using: :btree

  create_table "website_members", force: :cascade do |t|
    t.integer "member_id"
    t.integer "website_id"
    t.integer "role",               default: 2
    t.string  "invitation_token"
    t.string  "invitation_sent_at"
    t.integer "notification_id"
  end

  add_index "website_members", ["member_id"], name: "index_website_members_on_member_id", using: :btree
  add_index "website_members", ["notification_id"], name: "index_website_members_on_notification_id", using: :btree
  add_index "website_members", ["website_id"], name: "index_website_members_on_website_id", using: :btree

  create_table "websites", force: :cascade do |t|
    t.string   "title",      null: false
    t.string   "domain",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "app_key"
    t.string   "app_secret"
  end

  add_foreign_key "issues", "subscribers"
  add_foreign_key "website_members", "notifications"
end
