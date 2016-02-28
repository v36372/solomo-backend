class PostsController < ApplicationController
  before_action :find_post, except: [:index, :new]

  def index
    @posts = Post.all
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      redirect_to posts_path
    else
      render :new
    end
  end

  def edit
    @post.assign_attributes()
  end

  def update
    @post.assign_attributes(post_params)
    if @post.save
      redirect_to posts_path
    else
      render :edit
    end
  end

  def destroy
  end

  private

  def post_params
    params.require(:post).permit!
  end

  def find_post
    @post = Post.find_by_id(params[:id])
  end
end
