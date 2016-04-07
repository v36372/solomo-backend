module Admin
  class CommentsController < AdminController
    before_action :find_post
    before_action :find_comment

    def create
      comment = Comment.new(comment_params)
      comment.post = @post
      if comment.save
        flash[:notice] = 'Post the comment successfully'
      else
        flash[:error] = comment.errors.full_messages.first
      end
      redirect_to :back
    end

    def destroy
      if @comment.present? && @comment.destroy
        flash[:notice] = 'Destroy the comment successfully'
      else
        flash[:notice] = 'Fail to destroy the comment'
      end
      redirect_to :back
    end

    private

    def comment_params
      params.require(:comment).permit(:user_id, :content, :parent_id)
    end

    def find_post
      @post = Post.find_by_id(params[:post_id])
    end

    def find_comment
      @comment = Comment.find_by(id: params[:id], post_id: params[:post_id])
    end
  end
end