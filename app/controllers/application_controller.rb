class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #before_action :authenticate_user!
  protect_from_forgery with: :exception

  def disable_on_production!
    return unless Rails.env.production?
    render :nothing => true, :status => 404, :content_type => 'text/html'
  end

  def authenticate_admin!
    if user_signed_in?
      unless current_user.is_admin?
        flash[:error] = 'You are not an admin. Get out!'
        redirect_to root_path
      end
    else
      flash[:error] = "You need to login before continue"
      redirect_to new_user_session_path
    end
  end

  def authenticate_store!
    if user_signed_in?
      if current_user.store.blank?
        redirect_to new_stores_registrations_path
      elsif !current_user.is_store?
        case current_user.store.status.to_sym
          when :created
            redirect_to edit_stores_registrations_path if params[:action] != 'edit' && params[:action] != 'update'
          when :processing_email
            if params[:action] != 'email' && params[:action] != 'process_email' && params[:action] != 'resend_email' && params[:action] != 'reset'
              redirect_to email_stores_registrations_path
            end
          when :processing_phone
            if params[:action] != 'phone' && params[:action] != 'process_phone' && params[:action] != 'resend_phone' && params[:action] != 'reset'
              redirect_to phone_stores_registrations_path
            end
        end
      end
    else
      flash[:error] = "You need to login before continue"
      redirect_to new_user_session_path
    end
  end
end
