class CreateUserTransactions < ActiveRecord::Migration
  def change
    create_table :user_transactions do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :amount
      t.integer :transactionable_id
      t.string :transactionable_type
      t.text :reason
    end
  end
end
