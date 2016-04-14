module Stores
  class PostsController < StoreController
    before_action :find_post, except: [:index]

    def index
      @page = params[:page] || 1
      @per_page = 10

      @posts = current_user.posts
                 .order("(select count(post_boosts.id) from post_boosts where post_boosts.active = 't' AND post_boosts.post_id = posts.id) desc")
                 .order(created_at: :desc)
                 .page(@page).per(@per_page)
    end

    def check_boost
      @last_post_boost = @post.post_boosts.order(created_at: :desc).first
    end

    def new_boost
      @boost = @post.post_boosts.build(age_min: 25, age_max: 30)
      @tags = Tag.pluck(:name)
    end

    def create_boost
      @boost = @post.post_boosts.build(age_min: boost_params[:age_min].to_i, age_max: boost_params[:age_max].to_i)
      params[:tags].to_s.split(',').each do |tag_name|
        tag = Tag.find_by_name(tag_name)
        next if tag.blank?
        @boost.post_boost_tags.new(tag: tag)
      end
      if @boost.save
        flash[:notice] = "Boost post sucesfully"
      else
        flash[:error] = @boost.errors.full_messages.first
      end
      redirect_to stores_posts_path
    end

    def estimate_boost
      @boost = @post.post_boosts.build(age_min: params[:age_min].to_i, age_max: params[:age_max].to_i)
      params[:tags].to_s.split(',').each do |tag_name|
        tag = Tag.find_by_name(tag_name)
        next if tag.blank?
        @boost.post_boost_tags.new(tag: tag)
      end
      respond_to do |format|
        format.js
      end
    end

    def activate_boost
      @post.post_boosts.order(created_at: :desc).first.update(active: true)
      render :render_post
    end

    def deactivate_boost
      @post.last_active_boost.update(active: false)
      render :render_post
    end

    private
    def find_post
      @post = Post.find_by_id(params[:id])
    end

    def boost_params
      params.require(:post_boost)
    end
  end
end