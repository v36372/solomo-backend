module API
  module V1
    class Comments < Grape::API
      include API::V1::Defaults

      resources :comments, desc: "Comments" do
        before do
          authenticate_user!
        end
        desc "Get all comments of a post"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          requires :post_id, type: Integer, desc: 'Post id'
        end
        get do

          @post = Post.find_by_id params[:post_id]
          if @post.blank?
            return {
              error: 'Post not found'
            }
          end

          return {
            count: @post.comments.count,
            comments: @post.comments.map(&:to_api_json)
          }
        end

        desc "Post a comment"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          requires :post_id, type: Integer, desc: 'Post id'
          requires :content, type: String, desc: 'Comment content'
        end
        post do
          @post = Post.find_by_id params[:post_id]
          if @post.blank?
            return {
              error: 'Post not found'
            }
          end
          comment = Comment.new(
            content: params[:content],
            parent_id: params[:parent_id],
            post: @post,
            user: current_user
          )
          if comment.save
            return comment.to_api_json
          else
            return {
              error: comment.errors.full_messages.first
            }
          end
        end

        desc "Destroy a comment"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
        end
        delete '/:comment_id' do
          @comment = Comment.find_by_id params[:comment_id]
          unless @comment.present?
            return {
              error: 'Comment not found'
            }
          end
          if @comment.destroy
            return  {}
          else
            return {
              error: @comment.errors.full_messages.first
            }
          end
        end
      end
    end
  end
end
