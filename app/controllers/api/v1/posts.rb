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
          optional :user_id, type: String, desc: 'User id want to fetch the posts'
        end
        get do
          @posts = Post.order(created_at: :desc)
          if params[:user_id].present?
            @posts = @posts.where(user_id: params[:user_id])
          end
          posts = @posts.map &:to_api_json
          return {
            posts: posts
          }
        end

        desc "Create a new post"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          optional :picture, desc: 'Picture to post'
          optional :picture_id, desc: 'Picture id of uploaded image to post'
          optional :picture_url, desc: 'Picture url that needs to create a post'
          requires :description, type: String, desc: 'Description of the post'
          optional :tags, type: String, desc: 'Arry of tag id attached to the post'
          optional :location_lat, type: Float, desc: 'Latitude of the post'
          optional :location_long, type: Float, desc: 'Longitude of the post'
          optional :start_date, type: String, desc: 'Start date of the post'
          optional :end_date, type: String, desc: 'End date of the post'

          optional :post_type, type: String, desc: 'Type of creating post'
          optional :crawl_user_name, type: String, desc: 'User name of crawled data'
          optional :crawl_user_email, type: String, desc: 'Email of crawled data'
          optional :crawl_user_avatar, type: String, desc: 'Avatar of crawled data'
        end
        post do
          @post = Post.new(
            description: params[:description],
            tag_ids: params[:tags].to_s.split(','),
            lat: params[:location_lat],
            long: params[:location_long],
            post_type: params[:post_type],
            post_type: params[:post_type]
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

          # Save post
          if @post.save
            return {
              id: @post.id,
              picture_url: @post.picture.url(:original),
              description: @post.description,
              tag_ids: @post.tags.map {|t| {id: t.id, name: t.name} },
              lat: @post.lat,
              long: @post.long,
              user: {
                  name: @post.user_name,
                  email: @post.user_email,
                  avatar_url: @post.user_avatar_url
              }
            }
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
