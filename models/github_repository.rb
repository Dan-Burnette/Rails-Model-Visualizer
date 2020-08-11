require 'base64'

class GithubRepository
  class NoSchemaFound < StandardError; end

  def initialize(client, github_repo_url)
    @client = client
    @repo = Octokit::Repository.from_url(github_repo_url)
  end

  def model_file_contents
    model_paths.map { |path| file_contents(path) }
  end

  def schema_file_content
    file_contents(schema_path)
  end

  private

  def file_contents(path)
    response = @client.contents(@repo, path: path)
    encoded_file_content = response[:content]
    Base64.decode64(encoded_file_content)
  end

  def model_paths
    model_elements.map { |e| e[:path] }
  end

  def model_elements
    tree.select do |e|
      e[:path].include?('app/models') && e[:path].include?('.rb')
    end
  end

  def schema_path
    schema_element[:path]
  end

  def schema_element
    element = tree.find { |e| e[:path] == 'db/schema.rb' }
    element ? element : raise(NoSchemaFound)
  end

  def tree
    @tree ||= @client.tree(@repo, default_branch_sha, recursive: true)[:tree]
  end

  def default_branch_sha
    branch_data = @client.branch(@repo, default_branch)
    branch_data[:commit][:sha]
  end

  def default_branch
    repository_data = @client.repository(@repo)
    repository_data[:default_branch]
  end
end
