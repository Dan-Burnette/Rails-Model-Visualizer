class ScrapersController < ApplicationController
  require "net/http"

  def show_all
    show_model_graph
    show_repo_controllers
  end

  def show_model_graph

    # Initial is githubprojecturl/tree/master/app
    new_start_url = params[:start_url] + '/tree/master/app/models'

    if (!url_exist?(new_start_url))
      flash[:alert] = "An invalid URL was entered"
      redirect_to :root
      return
    end

    # Scrape for models and their URLS 
    # @directory_urls = []
    @models = []
    @models_that_extend_active_record_base = []
    @model_to_model_it_extends = {}
    @model_urls = []




    # Go through all directories recursively and grab the URLS for each file,
    # pushing them into @directory_urls
    directory_urls = ScrapeAllUrls.run(new_start_url)


    # From these URLS, find the models and their URLs, pushing them into @model_urls
    get_models_and_urls(directory_urls)

    # Scrape each model page for their ActiveRecord assocations
    all_relationships = GetModelAssociations.run(@model_urls)

    # Scrape the Schema and map each table to its model
    schema_url = params[:start_url] + '/blob/master/db/schema.rb'
    if (url_exist?(schema_url))
      @model_to_data = GetSchemaData.run(schema_url)
    else
      redirect_to :root
      flash[:alert] = "That project doesn't have a DB schema file! Not going to work...try another!"
      return
    end

    # Classes that extend classes which extend activeRecord base must also have their schemas
    # populated with the schema of the class they extend
    @model_to_model_it_extends.each do |model, extends|
      data = @model_to_data[extends]
      @model_to_data.store(model, data)
    end

    # Graphing it
    graph_title = params[:start_url].split('/')[-1]
    graph_information = {graph_title: graph_title, models: @models, all_relationships: all_relationships }
    CreateGraph.run(graph_information)

  end

  def show_repo_controllers

    #Find all the controller URLs
    new_start_url = params[:start_url] + '/tree/master/app/controllers'
    directory_urls = ScrapeAllUrls.run(new_start_url)
    @controller_urls = get_controller_urls(directory_urls)

    #Parse controller names out of their URLs, and gather their actions
    #{controller => array of actions}
    @controllers = {}
    @controller_urls.each do |url|
      name = url.split('/')[-1].split('_')[0]
      actions = get_controller_actions(url)
      @controllers.store(name, actions)
    end

    # Create a graph for each controller representing what actions they have
    # Create a node for each controller, and create nodes for each action, connecting them to their controller
    @controllers.each do |name, actions|
      g = GraphViz.new(:G, :type => :digraph )
      controller_node = g.add_nodes(name)
      actions.each do |a|
        action_node = g.add_nodes(a)
        edge = g.add_edges(controller_node, action_node)
        action_node[:style => 'filled']
        action_node[:fillcolor => "red"]
      end
      controller_node[:style => 'filled']
      controller_node[:fillcolor => "blue"]
      g.output(:svg => "app/assets/images/#{name}.svg")
    end

  end

end
