class CreatePostBoost < ActiveRecord::Migration
  def change
    create_table :post_boosts do |t|
      t.references :post, index: true, foreign_key: true
      t.integer :age_min
      t.integer :age_max
      t.boolean :active, default: true
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
