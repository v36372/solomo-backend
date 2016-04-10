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

ActiveRecord::Schema.define(version: 20160410053325) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "content"
    t.integer  "parent_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "notification_type"
    t.boolean  "read",              default: false
    t.text     "message"
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.integer  "notifier_id"
    t.integer  "receiver_id"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "pg_search_documents", ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id", using: :btree

  create_table "pictures", force: :cascade do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "post_likes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_likes", ["post_id"], name: "index_post_likes_on_post_id", using: :btree
  add_index "post_likes", ["user_id"], name: "index_post_likes_on_user_id", using: :btree

  create_table "post_tags", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_tags", ["post_id"], name: "index_post_tags_on_post_id", using: :btree
  add_index "post_tags", ["tag_id"], name: "index_post_tags_on_tag_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "description"
    t.float    "lat"
    t.float    "long"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "picture_file_name",    limit: 255
    t.string   "picture_content_type", limit: 255
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "post_type"
    t.text     "crawl_user_name"
    t.text     "crawl_user_avatar"
    t.string   "crawl_user_email"
    t.text     "address"
    t.string   "promotion_type"
    t.text     "promotion_value"
  end

  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "stores", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "website"
    t.text     "description"
    t.text     "address"
    t.float    "location_lat"
    t.float    "location_long"
    t.string   "phone"
    t.string   "status"
    t.integer  "balance"
    t.integer  "total_balance"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verify_code"
    t.text     "feedback_content"
  end

  add_index "stores", ["user_id"], name: "index_stores_on_user_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_followings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "following_id"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "user_followings", ["user_id"], name: "index_user_followings_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 191
    t.string   "encrypted_password",     limit: 191
    t.string   "reset_password_token",   limit: 191
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 191
    t.string   "last_sign_in_ip",        limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",             limit: 191
    t.string   "last_name",              limit: 191
    t.string   "phone",                  limit: 191
    t.datetime "birthday"
    t.string   "provider",               limit: 191
    t.string   "uid",                    limit: 191
    t.text     "facebook_token"
    t.datetime "facebook_expires_at"
    t.integer  "province_id"
    t.integer  "district_id"
    t.string   "avatar_file_name",       limit: 255
    t.string   "avatar_content_type",    limit: 255
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "authentication_token",   limit: 191
    t.boolean  "is_admin"
  end

  add_foreign_key "post_likes", "posts"
  add_foreign_key "post_likes", "users"
  add_foreign_key "post_tags", "posts"
  add_foreign_key "post_tags", "tags"
  add_foreign_key "posts", "users"
  add_foreign_key "stores", "users"
  add_foreign_key "user_followings", "users"
end
