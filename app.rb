require_relative "services/fetch_repository_model_file_contents"
require_relative "services/extract_association_lines"
require_relative "services/parse_association_line"
require_relative "services/get_schema_data"
require_relative "services/create_graph"

get '/' do
  erb :index
end

get '/visualize' do

  if (!url_exist?(params[:start_url]))
    # flash[:alert] = "An invalid URL was entered"
    # redirect_to :root
    # return
  end

  models_to_file_contents = FetchRepositoryModelFileContents.call(params[:start_url])

  models_to_associations = {}
  models_to_file_contents.each do |model, file_contents|
    association_lines = ExtractAssociationLines.call(file_contents) 
    associations = association_lines.map { |l| ParseAssociationLine.call(model, l) }
    models_to_associations[model] = associations
  end

  # From these URLS, find the models and their URLs. Also identify those
  # which extend activeRecord::Base through an intermediate class
  # model_info = ScrapeModelData.call(model_urls)
  # models = model_info[:models]
  # model_to_model_it_extends = model_info[:model_to_model_it_extends]

 # puts "Model info"
  # puts model_info.inspect

  # Scrape each model page for their ActiveRecord assocations
  # all_relationships = GetModelAssociations.run(model_urls)

  # puts "all relationships"
  # puts all_relationships.inspect

  # Scrape the Schema and map each table to its model
  schema_url = params[:start_url] + '/blob/master/db/schema.rb'
  if (url_exist?(schema_url))
    @model_to_data = GetSchemaData.run(schema_url)
  else
    redirect_to :root
    flash[:alert] = "That project doesn't have a DB schema file! Not going to work...try another!"
    return
  end

  # Graphing it
  graph_title = params[:start_url].split('/')[-1]
  CreateGraph.call(graph_title, models_to_associations)

  erb :show_all
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



