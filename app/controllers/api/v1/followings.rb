module API
  module V1
    class Followings < Grape::API
      include API::V1::Defaults

      resource :followings, desc: "Followings" do
        desc "Get list of followings of a user"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
        end
        get do
        end
      end
    end
  end
end
