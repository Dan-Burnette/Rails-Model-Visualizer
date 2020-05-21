require 'rubygems'
require 'bundler'
require 'dotenv/load'

Bundler.require

require './app'

Rollbar.configure do |config|
  config.access_token = ENV.fetch("ROLLBAR_ACCESS_TOKEN")
end

run Sinatra::Application
