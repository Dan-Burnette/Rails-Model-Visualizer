require "base64"
require_relative "models/github_repository"
require_relative "models/association"
require_relative "services/application_service"
require_relative "services/parse_associations"
require_relative "services/extract_association_lines"
require_relative "services/parse_association_line"
require_relative "services/parse_schema_tables"
require_relative "services/create_graph"

get '/' do
  erb :index
end

get '/visualize_repo' do
  repository = GithubRepository.new(root_url)

  models_to_associations = {}
  repository.models_to_file_contents.each do |model, file_contents|
    models_to_associations[model] = ParseAssociations.call(model, file_contents)
  end

  CreateGraph.call(graph_title, models_to_associations)

  @models_to_column_lines = ParseSchemaTables.call(repository.schema_file_content)

  erb :visualize
end

def graph(repo)

end

def root_url
  params[:repo_root_url]
end

def graph_title
  root_url.split('/')[-1]
end

def inline_svg(file_name)
  file_path = "public/images/#{file_name}"
  File.read(file_path) 
end
