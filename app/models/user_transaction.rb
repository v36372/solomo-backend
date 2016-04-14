class UserTransaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :transactionable, polymorphic: true
end