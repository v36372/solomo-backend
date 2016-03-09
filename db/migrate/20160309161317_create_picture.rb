class CreatePicture < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string   "file_file_name"
      t.string   "file_content_type"
      t.integer  "file_file_size"
      t.datetime "file_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
