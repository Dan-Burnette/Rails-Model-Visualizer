require 'rubygems'
require 'bundler'

if ENV.fetch("APP_ENV") == "development"
  require 'dotenv/load'
end

Bundler.require

require './app'

Rollbar.configure do |config|
  config.access_token = ENV.fetch("ROLLBAR_ACCESS_TOKEN")
end

run Sinatra::Application
