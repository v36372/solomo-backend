module Stores
  class DashboardsController < StoreController
    before_action :authenticate_store!
    def show

    end
  end
end