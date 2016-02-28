require File.expand_path("../../config/environment", __FILE__)
require 'spec_helper'
require 'rspec/rails'
ENV['RAILS_ENV'] ||= 'test'
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  Time.zone = "Asia/Bangkok"
  config.before(:each) do
    OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new({
      uid: "123456",
      info: {
        first_name: "Hello",
        last_name: "World",
        email: "hello_world@lixibox.com"
      },
      credentials: {
        expires_at: 1.year.from_now
      }
    })
  end
  config.infer_spec_type_from_file_location!
end
