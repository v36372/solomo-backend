class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def disable_on_production!
    return unless Rails.env.production?
    render :nothing => true, :status => 404, :content_type => 'text/html'
  end
end
