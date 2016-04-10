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

  namespace :stores do
    root to: 'dashboards#show'
    resource :dashboards
    resource :registrations, only: [:show, :new, :edit, :create, :update] do
      get :email
      post :process_email
      post :resend_email
      get :phone
      post :process_phone
      post :resend_phone
      post :reset
      get :staff
      get :finish
    end
    resources :payments
    resources :posts
    resources :people
    resources :followers
    resources :profiles
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

    resources :stores do
      member do
        get :map
        post :next_status
        get :reject
        post :process_reject
      end
      collection do
        get :processing
      end
    end
  end
end
