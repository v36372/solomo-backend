module API
  module V1
    class Omniauth < Grape::API
      include API::V1::Defaults

      resource :omniauth, desc: "Social Login" do
        desc "Facebook login" do
          detail %Q{
            Use curl command line to test api:
            ```curl -H Content-Type:application/json -X POST -d '{"facebook_token":"xxxxxxxxxxxx"}' http://staging.lixibox.com/api/v1/omniauth```
            After authorize successful the server response an ```access token```. You should store this token for next time to request
          }
        end
        params do
          optional :facebook_token, type: String, desc: "Facebook token"
        end
        post :facebook do
          token = params[:facebook_token]
          return error!("Facebook token is invalid!", 422) unless token.present?

          graph = FbGraph::User.new('me?fields=id,first_name,last_name,email,picture.type(large)', access_token: token).fetch
          user  = User.find_by(email: graph.email) || User.new(email: graph.email)

          auth_struct = OpenStruct.new({
            uid: graph.identifier,
            info: OpenStruct.new({
              first_name: graph.first_name,
              last_name:  graph.last_name,
              email:      graph.email
            }),
            credentials: OpenStruct.new({
              expires_at: Time.now,
              token: token
            })
          })

          user.assign_fb_attributes(auth_struct)

          unless user.encrypted_password
            new_password  = SecureRandom.hex(10)
            user.password = user.password_confirmation = new_password
          end

          if user.save
            return { user_token: user.authentication_token }
          else
            errors = { errors: user.errors }
            error!(errors, 422)
          end
        end
      end
    end
  end
end
