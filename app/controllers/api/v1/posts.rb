module API
  module V1
    class Posts < Grape::API
      include API::V1::Defaults

      resources :posts, desc: "Posts" do
        before do
          authenticate_user!
        end

        desc "Get all posts"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          optional :liked_by_id, type: Integer, desc: 'Filter posts liked by a user'
          optional :user_id, type: String, desc: 'Filter by posts author'
          optional :tags, type: Array[String], desc: 'Filter posts that have tags'
          optional :page, type: Integer, desc: 'Page want to fetch'
        end
        get do
          per_page = 20
          page = (params[:page] || 1).to_i
          @posts = Post.order(created_at: :desc)
          if params[:user_id].present?
            @posts = @posts.where(user_id: params[:user_id])
          end
          if params[:tags].present?
            tag_ids = Tag.where(name: params[:tags].map(&:strip).compact).pluck(:id)
            post_ids = PostTag.where(tag_id: tag_ids).pluck(:post_id)
            @posts = @posts.where(id: post_ids)
          end
          if params[:liked_by_id].present?
            like_post_ids = PostLike.where(user_id: params[:liked_by_id]).pluck(:post_id)
            @posts = @posts.where(id: like_post_ids)
          end
          if page.present?
            @posts = @posts.page(page).per(per_page)
          end
          posts = @posts.map &:to_api_json
          {
            posts: posts,
            pagination: {
              current_page: page,
              total_pages: @posts.total_pages
            }
          }
        end

        desc "Create a new post"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          optional :picture, desc: 'Picture to post'
          optional :picture_id, desc: 'Picture id of uploaded image to post'
          optional :picture_url, desc: 'Picture url that needs to create a post'
          requires :description, type: String, desc: 'Description of the post'
          optional :tags, type: Array[String], desc: 'Arry of tag id attached to the post'
          optional :location_lat, type: Float, desc: 'Latitude of the post'
          optional :location_long, type: Float, desc: 'Longitude of the post'
          optional :start_date, type: String, desc: 'Start date of the post'
          optional :end_date, type: String, desc: 'End date of the post'
          optional :promotion_type, type: String, desc: 'Promotion type. Allowed values: discount, bonus'
          optional :promotion_value, type: String, desc: 'Value of the promotion. For example: if you want to mark this post discount 30%, set promotion_type = "discount" and promotion_value = "30%"'

          optional :post_type, type: String, desc: 'Type of creating post'
          optional :crawl_user_name, type: String, desc: 'User name of crawled data'
          optional :crawl_user_email, type: String, desc: 'Email of crawled data'
          optional :crawl_user_avatar, type: String, desc: 'Avatar of crawled data'
        end
        post do
          @post = Post.new(
            description: params[:description],
            lat: params[:location_lat],
            long: params[:location_long],
            post_type: params[:post_type],
            promotion_type: params[:promotion_type],
            promotion_value: params[:promotion_value]
          )

          # Post picture
          if params[:picture_id].present?
            picture = Picture.find_by_id params[:picture_id]
            if picture.present?
              @post.picture = picture.file
            else
              return {
                  error: 'Picture not found'
              }
            end
          elsif params[:picture_url].present?
            @post.picture_url = params[:picture_url]
          else
            picture = params[:picture]
            attachment = {
                :filename => picture[:filename],
                :type => picture[:type],
                :headers => picture[:head],
                :tempfile => picture[:tempfile]
            }
            @post.picture = ActionDispatch::Http::UploadedFile.new(attachment)
          end

          # Crawl data
          if @post.post_type == 'crawl'
            @post.assign_attributes(
                crawl_user_name: params[:crawl_user_name],
                crawl_user_email: params[:crawl_user_email],
                crawl_user_avatar: params[:crawl_user_avatar]
            )
          else
            @post.user = current_user
          end

          # Post tags
          tag_names = params[:tags] || []
          tag_names.map(&:strip).uniq.compact.each do |tag_name|
            tag = Tag.find_or_create_by(name: tag_name)
            @post.tags << tag if tag.present?
          end

          # Save post
          if @post.save
            @post.to_api_json
          else
            errors = {error: @post.errors}
            return errors
          end
        end

        route_param :post_id do
          before do
            @post = Post.find_by_id params[:post_id]
          end

          desc "Get post information"
          params do
            requires :user_token, type: String, desc: 'Generated user token'
          end
          get do
            return @post.to_api_json
          end

          desc "Update description of the post"
          params do
            requires :user_token, type: String, desc: 'Generated user token'
            requires :description, type: String, desc: 'Description to update'
          end
          patch :update_description do
            @post.assign_attributes(
              description: params[:description]
            )
            if @post.save
              return {
                id: @post.id,
                description: @post.description
              }
            else
              errors = {error: @post.errors}
              return errors
            end
          end

          desc "Update location of the post"
          params do
            requires :user_token, type: String, desc: 'Generated user token'
            requires :location_lat, type: Float, desc: 'Latitude of the post'
            requires :location_long, type: Float, desc: 'Longitude of the post'
          end
          patch :update_location do
            @post.assign_attributes(
              lat: params[:location_lat],
              long: params[:location_long]
            )
            if @post.save
              return {
                id: @post.id,
                location_lat: @post.lat,
                location_long: @post.long
              }
            else
              errors = {error: @post.errors}
              return errors
            end
          end

          desc "Remove post"
          params do
            requires :user_token, type: String, desc: 'Generated user token'
          end
          delete do
            if @post.destroy
              return {}
            else
              errors = {error: @post.errors}
              return errors
            end
          end
        end
      end
    end
  end
end
