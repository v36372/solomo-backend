class CreateUserPayments < ActiveRecord::Migration
  def change
    create_table :user_payments do |t|
      t.references :user, index: true, foreign_key: true
      t.text :detail
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :amount
      t.string :external_id
    end
  end
end
