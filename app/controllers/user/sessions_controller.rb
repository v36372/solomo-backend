class User::SessionsController < Devise::SessionsController
  before_filter :skip_signup_modal

  def create
    self.resource = warden.authenticate(auth_options)
    if self.resource
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      yield resource if block_given?

      if params[:login_for] == "checkout"
        render js: "window.location='#{checkout_cart_path}'"
      elsif params[:login_for] == 'popup_login'
        render js: "window.location='#{params[:after_login_path]}'"
      else
        if request.xhr?
          return
        else
          respond_with resource, location: after_sign_in_path_for(resource)
        end
      end
    else
      self.resource ||= User.new
      flash.now[:alert] = i18n_message(:invalid)
      if params[:login_for] == "waitlist"
        @box = Box.approved.find_by_slug params[:box_slug]
        if @box
          render template: "shoppings/waitlist"
        else
          render template: "devise/sessions/new"
        end
      elsif params[:login_for] == "checkout"
        session[:order] ||= {}
        @cart = ShoppingCart.new(session, resource)
        @order = @cart.order
        @user = @cart.user
        respond_to do |format|
          format.html {
            render template: "carts/checkout"
          }
          format.js {
            render template: "user/sessions/create.js.erb"
          }
        end
      elsif params[:login_for] == 'popup_login'
        resource.errors.add(:error, i18n_message(:invalid))
        render 'shared/popup_login/failed.js.erb'
      else
        if request.xhr?
          return
        else
          render template: "devise/sessions/new"
        end
      end
    end
  end

  def after_sign_in_path_for(resource)
    if params[:login_for] == "waitlist"
      @box = Box.approved.find_by_slug params[:box_slug]
      @box ? waitlist_shopping_path(@box) : super
    elsif params[:login_for] == "checkout"
      checkout_cart_path
    elsif params[:login_for] == "expert"
      new_expert_register_path
    elsif params[:login_for] == "promoter"
      new_promoter_register_path
    elsif params[:login_for] == "topic"
      params[:login_return_path] || topics_path
    else
      session[:user_return_to] = params[:return_to]
      super
    end
  end

  def i18n_message(message)
    if message.is_a?(Symbol)
      options = {}
      options[:resource_name] = :user
      options[:scope] = "devise.failure"
      options[:default] = [message]
      auth_keys = scope_class.authentication_keys
      keys = auth_keys.respond_to?(:keys) ? auth_keys.keys : auth_keys
      options[:authentication_keys] = keys.join(I18n.translate(:"support.array.words_connector"))

      I18n.t(:"#{scope}.#{message}", options)
    else
      message.to_s
    end
  end

  def scope
    @scope ||= Devise.default_scope
  end

  def scope_class
    @scope_class ||= Devise.mappings[scope].to
  end

  def skip_signup_modal
    @skip_signup_modal = true
  end
end

