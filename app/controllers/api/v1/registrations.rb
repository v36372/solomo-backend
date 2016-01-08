module API
  module V1
    class Registrations < Grape::API
      include API::V1::Defaults

      resource :registrations, desc: "Registration" do
        desc "Register user and return user object, access token"
        params do
          optional :email,    type: String, desc: "Email"
          optional :password, type: String, desc: "Password"
          optional :phone,    type: String, desc: "Phone"
        end
        post do
          user = User.new(permitted_params)
          if user.valid?(:api)
            user.ensure_authentication_token
            user.save(context: :api)

            status 200
            {access_token: user.authentication_token, user: UserSerializer.new(user, root: false)}
          else
            error!(user.errors , 422)
          end
        end
      end
    end
  end
end
