require_relative "application_service"

class FetchRepositoryModelUrls < ApplicationService

  def initialize(github_repo_url)
    @repo_url = github_repo_url
    @repo = Octokit::Repository.from_url(github_repo_url)
  end

  def call
    begin
      repo_model_file_urls
    rescue Octokit::Error => e
      e.response_body
    end
  end

  private

  def master_branch_sha
    branch_data = Octokit.branch(@repo, "master")
    branch_data[:commit][:sha]
  end

  def repo_tree
    tree_data = Octokit.tree(@repo, master_branch_sha, recursive: true)
    tree_data[:tree]
  end

  def repo_model_files
    repo_tree.select { |e| e[:path].include?("app/models") && e[:path].include?(".rb") }
  end

  def repo_model_file_urls
    repo_model_files.map { |f| "#{@repo_url}/blob/master/#{f[:path]}" }
  end

end
