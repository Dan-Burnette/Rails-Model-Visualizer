require_relative "services/fetch_repository_model_file_contents"
require_relative "services/extract_association_lines"
require_relative "services/parse_association_line"
require_relative "services/get_schema_data"
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

  models_to_file_contents = FetchRepositoryModelFileContents.call(params[:repo_root_url])

  models_to_associations = {}
  models_to_file_contents.each do |model, file_contents|
    association_lines = ExtractAssociationLines.call(file_contents) 
    associations = association_lines.map { |l| ParseAssociationLine.call(model, l) }
    models_to_associations[model] = associations
  end

  @model_to_data = GetSchemaData.run(schema_url)

  # Graphing it
  graph_title = params[:repo_root_url].split('/')[-1]
  CreateGraph.call(graph_title, models_to_associations)

  erb :show_all
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



