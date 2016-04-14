class AddTimestampToUserTransactions < ActiveRecord::Migration
  def change
    add_column :user_transactions, :created_at, :datetime
    add_column :user_transactions, :updated_at, :datetime
  end
end
