module API
  module V1
    class Followers < Grape::API
      include API::V1::Defaults

      resource :followers, desc: "Followers" do
        desc "Get list of followers of a user"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
        end
        get do
        end

        desc "Follow a user"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          requires :user_id, type: Integer, desc: 'User id of target user'
        end
        post do
        end

        desc "Unfollow"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          requires :user_id, type: Integer, desc: 'User id of target user'
        end
        delete do
        end
      end
    end
  end
end
