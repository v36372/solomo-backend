module Admin
  class UsersController < AdminController
    def index
      @page = params[:page] || 1
      @per_page = 20

      @users = User.all.page(@page).per(@per_page)
    end
  end
end