module API
  module V1
    class Account < Grape::API
      include API::V1::Defaults

      resource :account, desc: "Account" do
        desc "Get user information (name, email, avatar url, ...)"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          optional :fields, type: Array, desc: 'Fields to return'
        end
        get do
        end

        desc "Update user information (name, birthday, location)"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          optional :name, type: String, desc: 'Updating user name'
          optional :birthday, type: String, desc: 'Updating birthday'
          optional :location_province, type: Integer, desc: 'Updating province id'
          optional :location_district, type: Integer, desc: 'Updating province id'
        end
        patch :personal_information do
        end

        desc "Update user avatar"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          optional :image, desc: 'Updating user avatar'
        end
        patch :avatar do
        end

        desc "Delete user avatar"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
        end
        delete :avatar do
        end
      end
    end
  end
end
