class ApplicationController < ActionController::Base
  require "net/http"
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  #For checking if the schema can be found
  def url_exist?(url_string)
    url = URI.parse(url_string)
    req = Net::HTTP.new(url.host, url.port)
    req.use_ssl = (url.scheme == 'https')
    path = url.path if url.path.present?
    res = req.request_head(path || '/')
    res.code != "404" # false if returns 404 - not found
  rescue Exception => e
    false # false if can't find the server
  end


end
