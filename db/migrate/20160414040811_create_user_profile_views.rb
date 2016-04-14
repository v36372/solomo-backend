class CreateUserProfileViews < ActiveRecord::Migration
  def change
    create_table :user_profile_views do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :target_user_id
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
