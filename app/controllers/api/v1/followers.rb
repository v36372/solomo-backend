module API
  module V1
    class Followers < Grape::API
      include API::V1::Defaults

      resource :followers, desc: "Followers" do
        before do
          authenticate_user!
        end

        desc "Get list of followers of a user"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          optional :user_id, type: Integer, desc: 'User to get followers from. If blank, the api will return follower users of the current user'
          optional :page, type: Integer, desc: 'Pagination'
        end
        get do
          page = params[:page] || 1
          per_page = 20

          user = params[:user_id].present? ? User.find_by_id(params[:user_id]) : current_user
          if user.present?
            @users = user.followers.page(page).per(per_page)
            return {
              followers: @users.map(&:to_api_json),
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

        desc "Follow a user"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          requires :following_id, type: Integer, desc: 'User id of target user'
        end
        post do
          following = User.find_by_id(params[:following_id])
          if following.present?
            user_following = UserFollowing.find_or_create_by(
              user: current_user,
              following: following
            )
            if user_following.errors.present?
              return {
                errors: user_following.errors.full_messages.first
              }
            elsif !user_following.persisted?
              return {
                errors: 'Fail to follow user'
              }
            else
              return {
                result: 'Follow successfully'
              }
            end
          else
            return {
              errors: 'User to follow not found'
            }
          end
        end

        desc "Unfollow"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          requires :user_id, type: Integer, desc: 'User id of target user'
        end
        delete do
          following = User.find_by_id(params[:user_id])
          if following.present?
            user_following = UserFollowing.find_by(
              user: current_user,
              following: following
            )
            if user_following.blank? || user_following.destroy
              return {
                result: 'Unfollow successfully'
              }
            else
              return {
                errors: 'Fail to unfollow'
              }
            end
          else
            return {
              errors: 'User to follow not found'
            }
          end
        end
      end
    end
  end
end
