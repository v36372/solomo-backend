module Admin
  class PostsController < AdminController
    before_action :find_post, except: [:index, :new]

    def index
      @page = params[:page] || 1
      @per_page = params[:per_page] || 20
      @posts = Post.all.order(created_at: :desc).page(@page).per(@per_page)
    end

    def new
      @post = Post.new
    end

    def create
      @post = Post.new(post_params)
      if @post.save
        redirect_to admin_posts_path
      else
        render :new
      end
    end

    def show
      user_ids = User.all.pluck(:id) - @post.post_likes.pluck(:user_id)
      @like_as = User.where(id: user_ids)
      @comment_as = User.all.pluck(:id)
    end

    def edit
    end

    def update
      @post.assign_attributes(post_params)
      if @post.save
        redirect_to admin_posts_path
      else
        render :edit
      end
    end

    def destroy
      @post.destroy
      flash[:notice] = 'Destroy the post successfully'
      redirect_to admin_posts_path
    end

    private

    def post_params
      params.require(:post).permit!
    end

    def find_post
      @post = Post.find_by_id(params[:id])
    end
  end
end