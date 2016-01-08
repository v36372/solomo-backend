module API
  module V1
    class Password < Grape::API
      include API::V1::Defaults

      resource :passwords, desc: "Forgot password" do
        desc 'returns reset_password_token'
        params do
          optional :email, type: String, desc: "Email"
        end
        post do
          unless params[:email].present? && params[:email] =~ Devise.email_regexp
            return error!("Vui lòng điền vào địa chỉ email hợp lệ.", 422)
          end

          if user = User.find_by_email(params[:email])
            user.send_reset_password_instructions
            status 200
          else
            error!("Email không tồn tại trong hệ thống.", 422)
          end
        end
      end
    end
  end
end
