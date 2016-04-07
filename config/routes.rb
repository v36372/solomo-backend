Rails.application.routes.draw do
  mount API::Base, at: "/"
  get "/api/docs" => 'docs#index'

  root 'static#landing_page'

  devise_for :users, controllers: {
  	omniauth_callbacks: "user/omniauth_callbacks",
  	registrations: "user/registrations",
    sessions: "user/sessions"
  }

  devise_scope :user do
    delete "users/guest_sign_out", to: "user/sessions#destroy_guest", as: :destroy_guest_user_session
  end

  resource :static do
    get :landing_page
  end

  namespace :store do
    resource :dashboard
  end

  namespace :admin do
    root to: 'dashboards#show'
    resource :dashboards
    resources :posts do
      resources :comments do
      end
      resources :post_likes do
      end
    end

    resources :users, only: [:index, :show, :edit] do
    end
  end
end
