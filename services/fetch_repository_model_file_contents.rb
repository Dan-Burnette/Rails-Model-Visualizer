require "base64"
require_relative "application_service"

class FetchRepositoryModelFileContents < ApplicationService

  def initialize(github_repo_url)
    @repo_url = github_repo_url
    @repo = Octokit::Repository.from_url(github_repo_url)
  end

  def call
    begin
      model_to_decoded_file_content
    rescue Octokit::Error => e
      e.response_body
    end
  end

  private

  def model_to_decoded_file_content
    repo_model_file_contents.inject({}) do |result, content_response|
      model_name = model_name(content_response)
      decoded_content = decoded_file_content(content_response)
      result[model_name] = decoded_content
      result
    end
  end

  def repo_model_file_contents
    repo_model_paths.map do |path|
      Octokit.contents(@repo, path: path)[:content]
    end
  end

  def model_name(content_response)
    file_name = content_response[:name]
    file_name.split('.')[0]
  end

  def decoded_file_content(content_response)
    encoded_file_content = content_response[:content]
    Base64.decode64(encoded_file_content)
  end

  def repo_model_paths
    repo_model_elements.map { |e| e[:path] }
  end

  def repo_model_elements
    repo_tree.select do |e|
      e[:path].include?("app/models") && e[:path].include?(".rb") 
    end
  end

  def repo_tree
    tree_data = Octokit.tree(@repo, master_branch_sha, recursive: true)
    tree_data[:tree]
  end

  def master_branch_sha
    branch_data = Octokit.branch(@repo, "master")
    branch_data[:commit][:sha]
  end

end
