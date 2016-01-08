module API
  module V1
    class PostLikes < Grape::API
      include API::V1::Defaults

      resource :post_like, desc: "Post likes" do
        desc "Get like list of a post"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          requires :post_id, type: Integer, desc: 'Id of the post want to get likes'
        end
        get do
        end

        desc "Like a post"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          requires :post_id, type: Integer, desc: 'Id of the post want to get likes'
          requires :user_id, type: Integer, desc: 'User id of user who likes the post'
        end
        post do
        end

        desc "Unlike a post"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          requires :post_id, type: Integer, desc: 'Id of the post want to get likes'
          requires :user_id, type: Integer, desc: 'User id of user who unlikes the post'
        end
        delete do
        end
      end
    end
  end
end
