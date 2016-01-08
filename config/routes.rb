Rails.application.routes.draw do
  mount API::Base, at: "/"
  get "/api/docs" => 'docs#index'
end
