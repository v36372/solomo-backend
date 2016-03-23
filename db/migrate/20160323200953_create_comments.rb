class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :user
      t.references :post
      t.datetime :created_at
      t.datetime :updated_at
      t.text :content
      t.integer :parent_id
    end
  end
end
