class CreateUserFeed < ActiveRecord::Migration
  def change
    create_table :user_feeds do |t|
      t.references :user, index: true, foreign_key: true
      t.references :post, index: true, foreign_key: true
      t.boolean :seen
      t.integer :related_score
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
