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

ActiveRecord::Schema.define(version: 20160610102447) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "grouped_issues", force: :cascade do |t|
    t.integer  "website_id"
    t.string   "issue_logger",     limit: 64
    t.string   "level",                       default: "error"
    t.text     "message"
    t.integer  "status",                      default: 3
    t.integer  "times_seen",                  default: 1
    t.datetime "first_seen"
    t.datetime "last_seen"
    t.integer  "score"
    t.integer  "time_spent_count",            default: 0
    t.datetime "resolved_at"
    t.datetime "active_at"
    t.string   "platform",         limit: 64
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "culprit"
    t.string   "checksum",         limit: 32
    t.integer  "time_spent_total",            default: 0
    t.integer  "release_id"
  end

  add_index "grouped_issues", ["active_at"], name: "index_grouped_issues_on_active_at", using: :btree
  add_index "grouped_issues", ["culprit"], name: "index_grouped_issues_on_culprit", using: :btree
  add_index "grouped_issues", ["first_seen"], name: "index_grouped_issues_on_first_seen", using: :btree
  add_index "grouped_issues", ["issue_logger"], name: "index_grouped_issues_on_issue_logger", using: :btree
  add_index "grouped_issues", ["last_seen"], name: "index_grouped_issues_on_last_seen", using: :btree
  add_index "grouped_issues", ["level"], name: "index_grouped_issues_on_level", using: :btree
  add_index "grouped_issues", ["release_id"], name: "index_grouped_issues_on_release_id", using: :btree
  add_index "grouped_issues", ["resolved_at"], name: "index_grouped_issues_on_resolved_at", using: :btree
  add_index "grouped_issues", ["status"], name: "index_grouped_issues_on_status", using: :btree
  add_index "grouped_issues", ["times_seen"], name: "index_grouped_issues_on_times_seen", using: :btree
  add_index "grouped_issues", ["website_id", "checksum"], name: "index_grouped_issues_on_website_id_and_checksum", unique: true, using: :btree
  add_index "grouped_issues", ["website_id"], name: "index_grouped_issues_on_website_id", using: :btree

  create_table "invites", force: :cascade do |t|
    t.integer  "invited_by_id"
    t.integer  "website_id"
    t.string   "email"
    t.string   "token"
    t.datetime "accepted_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "issues", force: :cascade do |t|
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "group_id"
    t.string   "platform"
    t.text     "data"
    t.integer  "time_spent"
    t.integer  "subscriber_id"
    t.string   "event_id"
    t.datetime "datetime"
    t.text     "message"
  end

  add_index "issues", ["datetime"], name: "index_issues_on_datetime", using: :btree
  add_index "issues", ["group_id"], name: "index_issues_on_group_id", using: :btree
  add_index "issues", ["subscriber_id"], name: "index_issues_on_subscriber_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.text     "content",    null: false
    t.integer  "issue_id",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "messages", ["issue_id"], name: "index_messages_on_issue_id", using: :btree

  create_table "releases", force: :cascade do |t|
    t.string   "version"
    t.jsonb    "data",       default: {}
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "website_id"
  end

  add_index "releases", ["website_id"], name: "index_releases_on_website_id", using: :btree

  create_table "subscribers", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "email",      null: false
    t.integer  "website_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "identity"
    t.string   "username"
    t.string   "ip_address"
  end

  add_index "subscribers", ["website_id", "email", "identity"], name: "index_subscribers_on_website_id_and_email_and_identity", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                               null: false
    t.string   "name",                                null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "provider",                            null: false
    t.string   "uid",                    default: "", null: false
    t.string   "password_digest",        default: "", null: false
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
    t.integer  "role",                   default: 2
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true, using: :btree

  create_table "website_members", force: :cascade do |t|
    t.integer "user_id"
    t.integer "website_id"
    t.integer "role",       default: 1
  end

  add_index "website_members", ["user_id"], name: "index_website_members_on_user_id", using: :btree
  add_index "website_members", ["website_id"], name: "index_website_members_on_website_id", using: :btree

  create_table "websites", force: :cascade do |t|
    t.string   "title",                          null: false
    t.string   "domain",                         null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "app_key"
    t.string   "app_secret"
    t.boolean  "new_event",      default: true
    t.boolean  "frequent_event", default: false
    t.boolean  "daily",          default: false
    t.boolean  "realtime",       default: false
    t.string   "platform"
    t.text     "origins",        default: "*"
  end

  add_foreign_key "grouped_issues", "releases"
  add_foreign_key "issues", "grouped_issues", column: "group_id", on_update: :restrict, on_delete: :cascade
  add_foreign_key "issues", "subscribers"
  add_foreign_key "releases", "websites"
end
