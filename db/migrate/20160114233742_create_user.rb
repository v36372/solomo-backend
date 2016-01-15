class CreateUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   "email",                       limit: 191
      t.string   "encrypted_password",          limit: 191
      t.string   "reset_password_token",        limit: 191
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",               limit: 4,     default: 0,     null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip",          limit: 191
      t.string   "last_sign_in_ip",             limit: 191
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "first_name",                  limit: 191
      t.string   "last_name",                   limit: 191
      t.string   "phone",                       limit: 191
      t.date     "birthday"
      t.string   "provider",                    limit: 191
      t.string   "uid",                         limit: 191
      t.text     "facebook_token",              limit: 65535
      t.datetime "facebook_expires_at"
      t.integer  "province_id",                 limit: 4
      t.integer  "district_id",                 limit: 4
      t.string   "avatar_file_name",            limit: 255
      t.string   "avatar_content_type",         limit: 255
      t.integer  "avatar_file_size",            limit: 4
      t.datetime "avatar_updated_at"
    end
  end
end
