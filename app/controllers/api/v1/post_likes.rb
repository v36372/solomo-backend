module API
  module V1
    class PostLikes < Grape::API
      include API::V1::Defaults

      resource :post_likes, desc: "Post likes" do
        before do
          authenticate_user!
          @post = Post.find_by_id params[:post_id]
        end

        desc "Get like list of a post"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          requires :post_id, type: Integer, desc: 'Post id'
        end
        get do
          if @post.blank?
            return {
              error: 'Post not found'
            }
          end
          return {
            count: @post.liked_users.count,
            likes: @post.liked_users.map do |user|
              {
                user_id: user.id,
                name: user.name,
                avatar_url: user.avatar.url(:thumb)
              }
            end
          }
        end

        desc "Like a post"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          requires :post_id, type: Integer, desc: 'Post id'
        end
        post :like do
          if @post.blank?
            return {
              error: 'Post not found'
            }
          end
          PostLike.find_or_create_by(user_id: current_user.id, post_id: @post.id)
          @post.reload
          return {
            count: @post.liked_users.count,
            likes: @post.liked_users.map do |user|
              {
                user_id: user.id,
                name: user.name,
                avatar_url: user.avatar.url(:thumb)
              }
            end
          }
        end

        desc "Unlike a post"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          requires :post_id, type: Integer, desc: 'Post id'
        end
        post :unlike do
          if @post.blank?
            return {
              error: 'Post not found'
            }
          end
          @like = PostLike.find_by(user_id: current_user.id, post_id: @post.id)
          @like.destroy if @like.present?
          @post.reload
          return {
            count: @post.liked_users.count,
            likes: @post.liked_users.map do |user|
              if user.present?
                {
                  user_id: user.id,
                  name: user.name,
                  avatar_url: user.avatar.url(:thumb)
                }
              else
                nil
              end
            end
          }
        end
      end
    end
  end
end
