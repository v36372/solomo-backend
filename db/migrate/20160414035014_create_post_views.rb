class CreatePostViews < ActiveRecord::Migration
  def change
    create_table :post_views do |t|
      t.references :user, index: true, foreign_key: true
      t.references :post, index: true, foreign_key: true
      t.integer :price
      t.integer :related_score
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
