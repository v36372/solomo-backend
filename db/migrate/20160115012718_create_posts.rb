class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :user, index: true, foreign_key: true
      t.text :description
      t.float :lat
      t.float :long
      t.datetime :start_date
      t.datetime :end_date
      t.string   "picture_file_name",            limit: 255
      t.string   "picture_content_type",         limit: 255
      t.integer  "picture_file_size",            limit: 4
      t.datetime "picture_updated_at"
    end
  end
end
