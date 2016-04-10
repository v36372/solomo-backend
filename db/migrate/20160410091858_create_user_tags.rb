class CreateUserTags < ActiveRecord::Migration
  def change
    create_table :user_tags do |t|
      t.references :user, index: true, foreign_key: true
      t.references :tag, index: true, foreign_key: true
      t.integer :score, default: 0
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
