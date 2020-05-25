require_relative "models/github_repository"
require_relative "models/association"
require_relative "services/parse_class_name"
require_relative "services/parse_associations"
require_relative "services/parse_schema_tables"
require_relative "services/create_graph"

get '/' do
  erb :index
end

get '/visualize_repo' do
  begin
    repo = GithubRepository.new(repo_url)
    CreateGraph.call(repo_name, models_to_associations(repo))
    @models_to_column_lines = ParseSchemaTables.call(repo.schema_file_content)
    erb :visualize
  rescue Octokit::NotFound, Octokit::InvalidRepository => error
    @error_message = "Couldn't find that repository. Is it entered correctly?"
    @attempted_url = repo_url
    erb :index
  rescue StandardError => error
    handle_unexpected_error(error)
    @error_message = "Something went wrong visualizing that repository. I'll look into a fix."
    @attempted_url = repo_url
    erb :index
  end
end

def repo_url
  params[:repo_root_url]
end

def repo_name
  repo_url.split('/')[-1]
end

def models_to_associations(repo)
  repo.model_file_contents.inject({}) do |result, file_contents|
    class_name = ParseClassName.call(file_contents)
    associations = ParseAssociations.call(class_name, file_contents)
    result[class_name] = associations
    result
  end
end


def handle_unexpected_error(error)
  production? ? Rollbar.error(error, url: repo_url) : raise(error)
end

def production?
  ENV.fetch("APP_ENV") == "production"
end

def inline_svg(file_name)
  file_path = "public/images/#{file_name}"
  File.read(file_path) 
end
