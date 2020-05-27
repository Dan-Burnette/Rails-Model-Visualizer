require_relative "application_service"

class CreateGithubClient < ApplicationService

  def initialize(access_token)
    @access_token = access_token
  end

  def call
    begin 
      client = user_client(@access_token)
      client.check_application_authorization(access_token: @access_token)
      client
    rescue Octokit::Unauthorized
      reset_invalid_access_token
      app_client
    end
  end

  private

  def user_client(access_token)
    Octokit::Client.new(access_token: access_token)
  end

  def app_client
    Octokit::Client.new(client_id: CLIENT_ID, client_secret: CLIENT_SECRET)
  end

  def reset_invalid_access_token
    session[:access_token] = nil
  end

end
