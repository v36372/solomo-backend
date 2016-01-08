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
