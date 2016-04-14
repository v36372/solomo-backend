module Stores
  class TransactionsController < StoreController
    def index
      @page = params[:page] || 1
      @per_page = 10
      @transactions = UserTransaction.where.not(amount: nil)
                                     .where('amount < 0')
                                     .page(@page)
                                     .per(@per_page)
    end
  end
end
