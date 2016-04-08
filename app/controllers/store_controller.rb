class StoreController < ApplicationController
  before_action :authenticate_user!
  layout 'stores'
end
