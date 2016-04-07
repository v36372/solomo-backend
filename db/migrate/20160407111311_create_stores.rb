class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.references :user, index: true, foreign_key: true
      t.text :website
      t.text :description
      t.text :address
      t.float :location_lat
      t.float :location_long
      t.string :phone
      t.string :status
      t.integer :balance
      t.integer :total_balance
    end
  end
end
