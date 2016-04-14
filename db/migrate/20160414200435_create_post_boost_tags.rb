class CreatePostBoostTags < ActiveRecord::Migration
  def change
    create_table :post_boost_tags do |t|
      t.references :post_boost, index: true, foreign_key: true
      t.references :tag, index: true, foreign_key: true
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
