module API
  module V1
    class Followings < Grape::API
      include API::V1::Defaults

      resource :followings, desc: "Followings" do
        before do
          authenticate_user!
        end

        desc "Get list of followings of a user"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          optional :user_id, type: Integer, desc: 'User to get followings from. If blank, the api will return following users of the current user'
          optional :page, type: Integer, desc: 'Pagination'
        end
        get do
          page = params[:page] || 1
          per_page = 20

          user = params[:user_id].present? ? User.find_by_id(params[:user_id]) : current_user
          if user.present?
            @users = user.followings.page(page).per(per_page)
            return {
              followings: @users.map(&:to_api_json),
              pagination: {
                current_page: page,
                total_pages: @users.total_pages
              }
            }
          else
            return{
              errors: 'User not found'
            }
          end
        end
      end
    end
  end
end
