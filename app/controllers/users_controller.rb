class UsersController < ApplicationController
  before_action :disable_on_production!
  def index
    @users = User.all
  end
end
