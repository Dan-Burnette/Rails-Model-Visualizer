require "base64"
require_relative "models/github_repository"
require_relative "models/association"
require_relative "services/application_service"
require_relative "services/extract_association_lines"
require_relative "services/parse_association_line"
require_relative "services/parse_schema"
require_relative "services/create_graph"

get '/' do
  erb :index
end

get '/visualize' do

  if !url_exist?(root_url)
    error_message = "An invalid URL was entered"
  elsif  !url_exist?(schema_url)
    error_message = "Can't find the DB schema file in this repository!"
  end

  repository = GithubRepository.new(root_url)

  models_to_associations = {}
  repository.models_to_contents.each do |model, file_contents|
    association_lines = ExtractAssociationLines.call(file_contents) 
    associations = association_lines.map { |l| ParseAssociationLine.call(model, l) }
    models_to_associations[model] = associations
  end

  @model_to_table = ParseSchema.call(repository.schema_content)

  graph_title = root_url.split('/')[-1]
  CreateGraph.call(graph_title, models_to_associations)

  erb :visualize
end

def root_url
  params[:repo_root_url]
end

def schema_url
  schema_url = root_url + '/blob/master/db/schema.rb'
end

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

def inline_svg(file_name)
  file_path = "public/images/#{file_name}"
  File.read(file_path) 
end



