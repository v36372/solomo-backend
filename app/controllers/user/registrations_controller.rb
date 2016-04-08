class User::RegistrationsController < Devise::RegistrationsController
  skip_before_action :authenticate_user!

  def new
    build_resource({})
    if session["devise.facebook_user"]
      resource.assign_attributes(session["devise.facebook_user"])
    end
    respond_with self.resource
  end

  def create
    build_resource(sign_up_params)

    resource.save
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      render after_sign_up_render_for(resource)
    end
  end

  def update
    super
  end

  private

  def skip_signup_modal
    @skip_signup_modal = true
  end

  def build_resource(hash=nil)
    hash ||= {}
    if hash[:email].present?
      if user = User.find_by(email: hash[:email])
        if user.encrypted_password.blank?
          self.resource = user
          self.resource.attributes = hash
        else
          super
        end
      else
        super
      end
    else
      super
    end
  end

  def after_sign_up_path_for(resource)
    if params[:register_for] == "waitlist"
      @box = Box.approved.find_by_slug params[:box_slug]
      @box ? waitlist_shopping_path(@box) : super
    elsif params[:register_for] == "checkout"
      checkout_cart_path
    elsif params[:register_for] == "expert"
      new_expert_register_path
    elsif params[:register_for] == "promoter"
      new_promoter_register_path
    else
      session[:user_return_to] = params[:return_to]
      super
    end
  end

  def after_sign_up_render_for(resource)
    if params[:register_for] == "waitlist"
      @box = Box.approved.find_by_slug params[:box_slug]
      @box ? "shoppings/waitlist" : "devise/registrations/new"
    elsif params[:register_for] == "checkout"
      session[:order] ||= {}
      @cart = ShoppingCart.new(session, resource)
      @order = @cart.order
      @user = @cart.user
      "carts/checkout"
    elsif params[:register_for] == "expert"
      @role = :expert
      @login_path = new_expert_register_path(account: :login)
      "expert/register/new"
    elsif params[:register_for] == "promoter"
      @role = :promoter
      @login_path = new_promoter_register_path(account: :login)
      "promoter/register/new"
    elsif params[:register_for] == "referrer"
      @referrer = User.find_by_id resource.referrer_id
      "user/profile/referrer"
    else
      "devise/registrations/new"
    end
  end

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :alias, :uid, :provider, :facebook_expires_at, :facebook_token, :password, :password_confirmation, :avatar_image, :referrer_id, :address, :province_id, :district_id, :ward)
  end
end

