module API
  module V1
    class Posts < Grape::API
      include API::V1::Defaults

      resource :post, desc: "Posts" do
        desc "Create a new post"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          requires :picture, desc: 'Picture to post'
          requires :description, type: String, desc: 'Description of the post'
          requires :tags, type: Array, desc: 'Arry of tag id attached to the post'
          optional :location_lat, type: Float, desc: 'Latitude of the post'
          optional :location_long, type: Float, desc: 'Longitude of the post'
          optional :start_date, type: Float, desc: 'Start date of the post'
          optional :end_date, type: Float, desc: 'End date of the post'
        end
        post do
        end

        route_param :id do
          desc "Update description of the post"
          params do
            requires :user_token, type: String, desc: 'Generated user token'
            requires :description, type: String, desc: 'Description to update'
          end
          patch :update_description do
          end

          desc "Update location of the post"
          params do
            requires :user_token, type: String, desc: 'Generated user token'
            requires :location_lat, type: Float, desc: 'Latitude of the post'
            requires :location_long, type: Float, desc: 'Longitude of the post'
          end
          patch :update_location do
          end

          desc "Update enable date"
          params do
            requires :user_token, type: String, desc: 'Generated user token'
            optional :start_date, type: Float, desc: 'Start date of the post'
            optional :end_date, type: Float, desc: 'End date of the post'
          end
          patch :update_endable_date do
          end

          desc "Remove post"
          params do
            requires :user_token, type: String, desc: 'Generated user token'
          end
          delete do
          end
        end
      end
    end
  end
end
