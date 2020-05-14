require_relative "application_service"

class FetchRepositoryFileUrls < ApplicationService

  def initialize(github_repo_url)
    @repo_url = github_repo_url
    @repo = Octokit::Repository.from_url(github_repo_url)
  end

  def call
    begin
      repo_ruby_file_urls
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

  def repo_ruby_files
    repo_tree.select { |e| e[:type] == "blob" && e[:path].include?(".rb") }
  end

  def repo_ruby_file_urls
    repo_ruby_files.map { |f| "#{github_repo_url}/{f[:path]}" }
  end

end
