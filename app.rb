require_relative "models/github_repository"
require_relative "models/association"
require_relative "services/parse_associations"
require_relative "services/parse_schema_tables"
require_relative "services/create_graph"

get '/' do
  erb :index
end

get '/visualize_repo' do
  begin
    repo = GithubRepository.new(root_url)
    CreateGraph.call(graph_title, models_to_associations(repo))
    @models_to_column_lines = ParseSchemaTables.call(repo.schema_file_content)
    erb :visualize
  rescue Octokit::NotFound, Octokit::InvalidRepository => error
    @error_message = "Couldn't find that repository. Is it entered correctly?"
    @attempted_url = root_url
    erb :index
  rescue StandardError => error
    Rollbar.error(error, url: root_url)
    @error_message = "Something went wrong visualizing that repository. I'll look into a fix."
    @attempted_url = root_url
    erb :index
  end
end

def root_url
  params[:repo_root_url]
end

def graph_title
  root_url.split('/')[-1]
end

def models_to_associations(repo)
  repo.models_to_file_contents.inject({}) do |result, (model, file_contents)|
    result[model] = ParseAssociations.call(model, file_contents)
    result
  end
end

def inline_svg(file_name)
  file_path = "public/images/#{file_name}"
  File.read(file_path) 
end
