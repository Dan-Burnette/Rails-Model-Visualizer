require "base64"

class GithubRepository

  def initialize(github_repo_url)
    @repo = Octokit::Repository.from_url(github_repo_url)
    @client = Octokit::Client.new(
      login: ENV.fetch("GITHUB_USERNAME"),
      password: ENV.fetch("GITHUB_PASSWORD")
    )
  end

  def models_to_file_contents
    model_file_contents.inject({}) do |result, content_response|
      model_name = file_name(content_response)
      decoded_content = decoded_file_content(content_response)
      result[model_name] = decoded_content
      result
    end
  end

  def schema_file_content
    content_response = file_contents(schema_path)
    decoded_file_content(content_response)
  end

  private

  def file_contents(path)
    @client.contents(@repo, path: path)
  end

  def file_name(content_response)
    file_name = content_response[:name]
    file_name.split('.')[0]
  end

  def decoded_file_content(content_response)
    encoded_file_content = content_response[:content]
    Base64.decode64(encoded_file_content)
  end

  def model_file_contents
    model_paths.map { |path| file_contents(path) }
  end

  def model_paths
    model_elements.map { |e| e[:path] }
  end

  def model_elements
    tree.select do |e|
      e[:path].include?("app/models") && e[:path].include?(".rb") 
    end
  end

  def schema_path
    schema_element[:path]
  end

  def schema_element
    tree.find { |e| e[:path].include?("schema.rb") }
  end

  def tree
    @tree ||= @client.tree(@repo, master_branch_sha, recursive: true)[:tree]
  end

  def master_branch_sha
    branch_data = @client.branch(@repo, "master")
    branch_data[:commit][:sha]
  end

end

