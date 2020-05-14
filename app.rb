require "net/http"
require "active_support/all"
require_relative "services/fetch_repository_file_urls"
require_relative "services/get_models_and_urls"
require_relative "services/get_model_associations"
require_relative "services/get_schema_data"
require_relative "services/create_graph"

get '/' do
  erb :index
end

get '/show_all' do
  show_model_graph
end

def show_model_graph

  if (!url_exist?(params[:start_url]))
    # flash[:alert] = "An invalid URL was entered"
    # redirect_to :root
    # return
  end

  file_urls = FetchRepositoryFileUrls.call(params[:start_url])

  puts "files count #{file_urls.count}"
  puts "file urls are"
  puts file_urls.inspect

  # From these URLS, find the models and their URLs. Also identify those
  # which extend activeRecord::Base through an intermediate class
  model_info = GetModelsAndUrls.run(file_urls)
  models = model_info[:models]
  model_to_model_it_extends = model_info[:model_to_model_it_extends]
  model_urls = model_info[:model_urls]

  puts "Model info"
  puts model_info.inspect

  # Scrape each model page for their ActiveRecord assocations
  all_relationships = GetModelAssociations.run(model_urls)

  puts "all relationships"
  puts all_relationships.inspect

  # Scrape the Schema and map each table to its model
  schema_url = params[:start_url] + '/blob/master/db/schema.rb'
  if (url_exist?(schema_url))
    @model_to_data = GetSchemaData.run(schema_url, model_to_model_it_extends)
  else
    redirect_to :root
    flash[:alert] = "That project doesn't have a DB schema file! Not going to work...try another!"
    return
  end

  # Graphing it
  graph_title = params[:start_url].split('/')[-1]
  graph_information = {graph_title: graph_title, models: models, all_relationships: all_relationships }
  CreateGraph.run(graph_information)

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

