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

ActiveRecord::Schema.define(version: 20160621072010) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     :index=>{:name=>"index_active_admin_comments_on_namespace"}
    t.text     "body"
    t.string   "resource_id",   :null=>false
    t.string   "resource_type", :null=>false, :index=>{:name=>"index_active_admin_comments_on_resource_type_and_resource_id", :with=>["resource_id"]}
    t.integer  "author_id"
    t.string   "author_type",   :index=>{:name=>"index_active_admin_comments_on_author_type_and_author_id", :with=>["author_id"]}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "websites", force: :cascade do |t|
    t.string   "title",          :null=>false
    t.string   "domain",         :null=>false
    t.datetime "created_at",     :null=>false
    t.datetime "updated_at",     :null=>false
    t.string   "app_key"
    t.boolean  "new_event",      :default=>true
    t.boolean  "frequent_event", :default=>false
    t.boolean  "daily",          :default=>false
    t.boolean  "realtime",       :default=>false
    t.string   "app_secret"
    t.string   "platform"
    t.text     "origins",        :default=>"*"
  end

  create_table "releases", force: :cascade do |t|
    t.string   "version"
    t.jsonb    "data",       :default=>{}
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
    t.integer  "website_id", :index=>{:name=>"index_releases_on_website_id"}, :foreign_key=>{:references=>"websites", :name=>"fk_releases_website_id", :on_update=>:restrict, :on_delete=>:cascade}
  end

  create_table "grouped_issues", force: :cascade do |t|
    t.integer  "website_id",       :index=>{:name=>"index_grouped_issues_on_website_id"}, :foreign_key=>{:references=>"websites", :name=>"fk_grouped_issues_website_id", :on_update=>:restrict, :on_delete=>:cascade}
    t.string   "issue_logger",     :limit=>64, :index=>{:name=>"index_grouped_issues_on_issue_logger"}
    t.string   "level",            :default=>"error", :index=>{:name=>"index_grouped_issues_on_level"}
    t.text     "message"
    t.integer  "status",           :default=>3, :index=>{:name=>"index_grouped_issues_on_status"}
    t.integer  "times_seen",       :default=>1, :index=>{:name=>"index_grouped_issues_on_times_seen"}
    t.datetime "first_seen",       :index=>{:name=>"index_grouped_issues_on_first_seen"}
    t.datetime "last_seen",        :index=>{:name=>"index_grouped_issues_on_last_seen"}
    t.integer  "score"
    t.integer  "time_spent_count", :default=>0
    t.datetime "resolved_at",      :index=>{:name=>"index_grouped_issues_on_resolved_at"}
    t.datetime "active_at",        :index=>{:name=>"index_grouped_issues_on_active_at"}
    t.string   "platform",         :limit=>64
    t.datetime "created_at",       :null=>false
    t.datetime "updated_at",       :null=>false
    t.string   "culprit",          :index=>{:name=>"index_grouped_issues_on_culprit"}
    t.string   "checksum",         :limit=>32
    t.integer  "time_spent_total", :default=>0
    t.integer  "release_id",       :index=>{:name=>"index_grouped_issues_on_release_id"}, :foreign_key=>{:references=>"releases", :name=>"fk_grouped_issues_release_id", :on_update=>:restrict, :on_delete=>:cascade}
  end
  add_index "grouped_issues", ["website_id", "checksum"], :name=>"index_grouped_issues_on_website_id_and_checksum", :unique=>true

  create_table "integrations", force: :cascade do |t|
    t.integer  "website_id",    :index=>{:name=>"index_integrations_on_website_id"}, :foreign_key=>{:references=>"websites", :name=>"fk_rails_ef5f282bb0", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "provider",      :null=>false
    t.text     "configuration"
    t.string   "name",          :null=>false
    t.boolean  "disabled",      :default=>false
    t.text     "error"
    t.datetime "created_at",    :null=>false
    t.datetime "updated_at",    :null=>false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  :null=>false, :index=>{:name=>"index_users_on_email", :unique=>true}
    t.string   "name",                   :null=>false
    t.datetime "created_at",             :null=>false
    t.datetime "updated_at",             :null=>false
    t.string   "provider",               :null=>false
    t.string   "uid",                    :default=>"", :null=>false, :index=>{:name=>"index_users_on_uid_and_provider", :with=>["provider"], :unique=>true}
    t.string   "password_digest",        :default=>"", :null=>false
    t.string   "reset_password_token",   :index=>{:name=>"index_users_on_reset_password_token", :unique=>true}
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default=>0, :null=>false
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
    t.integer  "role",                   :default=>2
  end

  create_table "invites", force: :cascade do |t|
    t.integer  "invited_by_id", :foreign_key=>{:references=>"users", :name=>"fk_invites_invited_by_id", :on_update=>:restrict, :on_delete=>:cascade}
    t.integer  "website_id",    :foreign_key=>{:references=>"websites", :name=>"fk_invites_website_id", :on_update=>:restrict, :on_delete=>:cascade}
    t.string   "email"
    t.string   "token"
    t.datetime "accepted_at"
    t.datetime "created_at",    :null=>false
    t.datetime "updated_at",    :null=>false
  end

  create_table "subscribers", force: :cascade do |t|
    t.string   "name",       :null=>false
    t.string   "email",      :null=>false
    t.integer  "website_id", :index=>{:name=>"index_subscribers_on_website_id_and_email_and_identity", :with=>["email", "identity"], :unique=>true}, :foreign_key=>{:references=>"websites", :name=>"fk_subscribers_website_id", :on_update=>:restrict, :on_delete=>:cascade}
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
    t.string   "identity"
    t.string   "username"
    t.string   "ip_address"
  end

  create_table "issues", force: :cascade do |t|
    t.datetime "created_at",    :null=>false
    t.datetime "updated_at",    :null=>false
    t.integer  "group_id",      :index=>{:name=>"index_issues_on_group_id"}, :foreign_key=>{:references=>"grouped_issues", :name=>"fk_issues_group_id", :on_update=>:restrict, :on_delete=>:cascade}
    t.string   "platform"
    t.text     "data"
    t.integer  "time_spent"
    t.integer  "subscriber_id", :index=>{:name=>"index_issues_on_subscriber_id"}, :foreign_key=>{:references=>"subscribers", :name=>"fk_issues_subscriber_id", :on_update=>:restrict, :on_delete=>:cascade}
    t.string   "event_id"
    t.datetime "datetime",      :index=>{:name=>"index_issues_on_datetime"}
    t.text     "message"
  end

  create_table "messages", force: :cascade do |t|
    t.text     "content",    :null=>false
    t.integer  "issue_id",   :null=>false, :index=>{:name=>"index_messages_on_issue_id"}, :foreign_key=>{:references=>"issues", :name=>"fk_messages_issue_id", :on_update=>:restrict, :on_delete=>:cascade}
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "website_members", force: :cascade do |t|
    t.integer "user_id",    :index=>{:name=>"index_website_members_on_user_id"}, :foreign_key=>{:references=>"users", :name=>"fk_website_members_user_id", :on_update=>:restrict, :on_delete=>:cascade}
    t.integer "website_id", :index=>{:name=>"index_website_members_on_website_id"}, :foreign_key=>{:references=>"websites", :name=>"fk_website_members_website_id", :on_update=>:restrict, :on_delete=>:cascade}
    t.integer "role",       :default=>1
  end

end
