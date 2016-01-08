require 'grape'

module API
  module V1
    module Config
      class ApiErrorHandler < Grape::Middleware::Base
        def call!(env)
          @env = env
          begin
            @app.call(@env)
          rescue StandardError => e
            ApiLogger.instance.error(env, e) #unless e.is_a? Grape::Exceptions::ValidationErrors
            raise e
          end
        end
      end
    end
  end
end
