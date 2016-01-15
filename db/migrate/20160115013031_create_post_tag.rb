class CreatePostTag < ActiveRecord::Migration
  def change
    create_table :post_tags do |t|
      t.references :post, index: true, foreign_key: true
      t.references :tag, index: true, foreign_key: true
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
