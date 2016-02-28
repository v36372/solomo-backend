Rails.application.routes.draw do
  mount API::Base, at: "/"
  get "/api/docs" => 'docs#index'

  root 'posts#index'

  resources :posts do
  end

  resources :users, only: [:index, :edit] do
  end
end
