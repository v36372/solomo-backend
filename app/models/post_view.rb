class PostView < ActiveRecord::Base
  belongs_to :user
  belongs_to :post, counter_cache: :views
  after_create :create_store_transaction

  private
  def create_store_transaction
    return if post.blank? || post.user.blank? || self.price.blank? || self.price == 0 || self.post.user.balance < self.price
    transaction do
      post.user.update(balance: self.post.user.balance - self.price)
      post.user.user_transactions.create(
        amount: -self.price,
        transactionable: self,
        reason: 'post_view'
      )
    end
  end
end