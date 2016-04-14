source 'https://rubygems.org'

gem 'rails', '4.2.5'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'bootstrap-sass'

gem 'paperclip'
gem 'pg'
gem 'pg_search'

gem 'devise'
gem 'devise-async'
gem 'omniauth-facebook'

gem 'babosa' # for better vietnamese slug
gem 'aasm' # for state machine
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sidetiq'
gem 'sinatra', require: false # for sidekiq web interface
gem 'impressionist' # analytics
gem 'mime-types', :require => 'mime/types' # for detecting mime types of files uploaded by paperclip

gem 'httparty'
gem 'fb_graph'
gem 'grape'
gem 'grape-swagger' # API docs
gem 'swagger-ui_rails' # API docs hosting
gem 'grape-active_model_serializers'
gem 'hashie-forbidden_attributes' # Strong parameters for grape
gem 'grape-route-helpers', require: false

gem 'haml-rails'
gem 'kramdown'

gem 'unicorn'

gem 'rollbar', '~> 2.5.0'
gem 'heroku_secrets', github: 'alexpeattie/heroku_secrets'
gem 'aws-sdk', '< 2.0'
gem 'kaminari'
gem 'pusher'

gem 'rack-cors'
gem 'compass-rails'

gem 'twilio-ruby'
gem 'mailgun_rails'
gem "font-awesome-rails"

gem 'stripe'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  gem 'web-console', '~> 2.0'
  gem 'better_errors'
  gem 'capistrano', '~> 3.0.1'
  gem 'capistrano-bundler'
  gem 'capistrano-rails', '~> 1.1.0'
  gem 'capistrano-rails-console'
  gem 'capistrano-rvm', '~> 0.1.1'
  gem 'html2haml'
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'spring-commands-rspec'
  gem "letter_opener"
  gem "parallel_tests"
  gem 'rspec-rails'
end

group :test do
  gem 'shoulda-matchers', '~> 3.0'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'thin'
  gem 'webmock'
end
