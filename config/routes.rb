Rails.application.routes.draw do
  mount API::Base, at: "/"
  get "/api/docs" => 'docs#index'

  root 'posts#index'

  resources :posts do
    resources :comments do
    end
    resources :post_likes do
    end
  end

  resources :users, only: [:index, :show, :edit] do
  end
end
