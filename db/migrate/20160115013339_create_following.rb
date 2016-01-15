class CreateFollowing < ActiveRecord::Migration
  def change
    create_table :user_followings do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :following_id
      t.datetime :updated_at
      t.datetime :created_at
    end
  end
end
