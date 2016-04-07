module Admin
  class PostLikesController < AdminController
    before_action :find_post
    before_action :find_post_like

    def create
      post_like = PostLike.new(post_like_params)
      post_like.post = @post
      if post_like.save
        flash[:notice] = 'Like successfully'
      else
        flash[:error] = post_like.errors.full_messages.first
      end
      redirect_to :back
    end

    def destroy
      if @post_like.present? && @post_like.destroy
        flash[:notice] = 'Destroy the like successfully'
      else
        flash[:notice] = 'Fail to destroy the like'
      end
      redirect_to :back
    end

    private

    def post_like_params
      params.require(:post_like).permit(:user_id)
    end

    def find_post
      @post = Post.find_by_id(params[:post_id])
    end

    def find_post_like
      @post_like = PostLike.find_by(id: params[:id], post_id: params[:post_id])
    end
  end
end