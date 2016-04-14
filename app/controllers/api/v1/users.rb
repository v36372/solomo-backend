module API
  module V1
    class Users < Grape::API
      include API::V1::Defaults

      resources :users, desc: "Users" do
        before do
          authenticate_user!
        end

        route_param :user_id do
          desc "Get user profile"
          params do
            requires :user_token, type: String, desc: 'Generated user token'
            requires :user_id, type: Integer, desc: 'User id of target user'
          end
          get do
            @user = User.find_by_id params[:user_id]
            if @user.blank?
              {
                errors: 'User not found'
              }
            else
              UserProfileView.create(
                user: current_user,
                target_user: @user
              )
              @user.to_api_json(include_store: true, include_posts: true, include_liked_posts: true)
            end
          end
        end
      end
    end
  end
end
