class User::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    auth = request.env["omniauth.auth"]
    @user = User.where(provider: auth.provider, uid: auth.uid).first
    unless @user
      if auth.info.email.blank?
        session["devise.facebook_user"] = {
          first_name: auth.info.first_name,
          last_name: auth.info.last_name,
          email: auth.info.email,
          uid: auth.uid,
          provider: "facebook",
          avatar_image: "https://graph.facebook.com/#{auth.uid}/picture?type=large",
          facebook_expires_at: auth.credentials.expires_at,
          facebook_token: auth.credentials.token
        }
        redirect_to new_user_registration_path(return_to: request.env['omniauth.origin'])
        return
      end

      @user ||= User.where(email: auth.info.email).first
      @user ||= User.new
      @user.assign_fb_attributes(auth)
      # set a random password if no password currently set
      # works for both a new user, and a user that was previously imported from another system
      unless @user.encrypted_password
        new_password = SecureRandom.hex(10)
        @user.password = @user.password_confirmation = new_password
      end

      if session[:referrer_id].present? && (@referrer = User.find_by_id(session[:referrer_id])).present?
        @user.referrer = @referrer
        session.delete(:referral_id)
      end
      @user.save
    end

    sign_in_and_redirect @user, :event => :authentication
    set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    # session["devise.facebook_user"] = @user
    # if request.env['omniauth.origin']
    #   if request.env['omniauth.origin'].in? [new_user_session_url, new_user_registration_url]
    #     redirect_to new_user_registration_path
    #   else
    #     redirect_to request.env['omniauth.origin']
    #   end
    # else
    #   redirect_to new_user_registration_path
    # end
  end
end

