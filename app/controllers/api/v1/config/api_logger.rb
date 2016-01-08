require 'singleton'

module API
  module V1
    module Config
      class ApiLogger
        include Singleton

        def initialize(logger = nil)
          if logger
            @logger = logger
          else
            @logger ||= Logger.new(File.join(Rails.root, "log/api.log"), 10, 1024000)
            @logger.level = Logger::INFO
          end
        end

        def error(env, error)
          msg = "#{ error.message } (#{ error.class }) \n \
          remote_address: #{ env['REMOTE_ADDR'] }\n \
          token: #{ env['HTTP_AUTHORIZATION'] }\n \
          method: #{ env['REQUEST_METHOD'] }\n \
          path: #{ env['PATH_INFO'] }\n \
          query: #{ Rack::Request.new(env).params }\n"
          msg << (error.backtrace || []).join("\n")
          @logger.error(msg)
        end
      end
    end
  end
end
