module API
  module V1
    class Posts < Grape::API
      include API::V1::Defaults

      resource :post, desc: "Posts" do
        before do
          authenticate_user!
        end

        desc "Get all posts"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
        end
        get do
          posts = Post.all.map do |post|
            {
              id: post.id,
              picture_url: post.picture.url(:original),
              description: post.description,
              tag_ids: post.tags.map {|t| {id: t.id, name: t.name} },
              lat: post.lat,
              long: post.long
            }
          end
          return {
            posts: posts
          }
        end

        desc "Create a new post"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          requires :picture, desc: 'Picture to post'
          requires :description, type: String, desc: 'Description of the post'
          requires :tags, type: String, desc: 'Arry of tag id attached to the post'
          optional :location_lat, type: Float, desc: 'Latitude of the post'
          optional :location_long, type: Float, desc: 'Longitude of the post'
          optional :start_date, type: String, desc: 'Start date of the post'
          optional :end_date, type: String, desc: 'End date of the post'
        end
        post do
          @post = Post.new(
            picture: params[:picture].file,
            description: params[:description],
            tag_ids: params[:tags].to_s.split(','),
            lat: params[:location_lat],
            long: params[:location_long]
          )
          if @post.save
            return {
              id: @post.id,
              picture_url: @post.picture.url(:original),
              description: @post.description,
              tag_ids: @post.tags.map {|t| {id: t.id, name: t.name} },
              lat: @post.lat,
              long: @post.long
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
            return {
              id: @post.id,
              picture_url: @post.picture.url(:original),
              description: @post.description,
              tag_ids: @post.tags.map {|t| {id: t.id, name: t.name} },
              lat: @post.lat,
              long: @post.long
            }
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
