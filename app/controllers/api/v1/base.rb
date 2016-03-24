require "grape-swagger"

module API
  module V1
    class Base < Grape::API
      version 'v1', using: :path
      prefix :api
      format :json

      ##################################
      # Mount API module
      mount API::V1::Registrations
      mount API::V1::Sessions
      mount API::V1::Password
      mount API::V1::Omniauth
      mount API::V1::Account
      mount API::V1::Tags
      mount API::V1::Posts
      mount API::V1::PostLikes
      mount API::V1::Tags
      mount API::V1::Followers
      mount API::V1::Followings
      mount API::V1::Feeds
      mount API::V1::Search
      mount API::V1::Pictures
      mount API::V1::Comments

      #################################
      # API Documentation
      add_swagger_documentation(
        api_version:'v1',
        mount_path: 'docs',
        markdown: GrapeSwagger::Markdown::KramdownAdapter,
        hide_documentation_path: true
      )
    end
  end
end
