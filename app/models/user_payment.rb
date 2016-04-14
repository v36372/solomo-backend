class UserPayment < ActiveRecord::Base
  belongs_to :user
  has_many :user_transactions, as: :transactionable

  after_create :add_to_user_balance

  private

  def add_to_user_balance
    transaction do
      user.update(balance: user.balance + self.amount)
      user.user_transactions.create(
        amount: self.amount,
        transactionable: self,
        reason: 'store_charge'
      )
    end
  end
end