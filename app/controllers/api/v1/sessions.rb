module API
  module V1
    class Sessions < Grape::API
      include API::V1::Defaults

      resource :sessions, desc: "LOGIN" do
        desc "Login returns access_token" do
          detail %Q{
            Use curl command line to test api:
            ```curl -H Content-Type:application/json -X POST -d '{"email":"luan@lixibox.com","password":"dangluan7"}' http://staging.lixibox.com/api/v1/sessions```
            After login successful the server response an ```access token```. You should stores this token for next time to request
          }
        end
        params do
          optional :email, type: String, desc: "User email"
          optional :password, type: String, desc: "User Password"
        end
        post do
          email = permitted_params[:email]
          password = permitted_params[:password]
          return error!("Invalid email or password", 422) unless email.present? && password.present?

          user = User.find_by_email(email.downcase)
          return error!("Invalid email or password", 422) unless user

          return error!("Invalid email or password", 422) unless user.valid_password?(password)

          if user.save(context: :api)
            status 200
            {access_token: user.authentication_token, user: UserSerializer.new(user, root: false)}
          else
            error!(user.errors, 500)
          end
        end

        desc "Logout, requires access_token"
        params do
          optional :access_token, type: String, desc: "Access Token"
        end
        delete do
          return error!("Invalid access token.", 422) unless params[:access_token].present?

          user = User.find_by(authentication_token: params[:access_token])
          return error!("Invalid access token.", 422) unless user

          user.authentication_token = nil
          user.save
          return {status: 200}
        end
      end
    end
  end
end
