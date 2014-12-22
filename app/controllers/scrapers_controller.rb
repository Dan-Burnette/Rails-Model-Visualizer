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

    # Go through all directories recursively and grab the URLS for each file
    directory_urls = ScrapeAllUrls.run(new_start_url)

    # From these URLS, find the models and their URLs. Also identify those 
    # which extend activeRecord::Base through an intermediate class
    model_info = GetModelsAndUrls.run(directory_urls)
    models = model_info[:models]
    model_to_model_it_extends = model_info[:model_to_model_it_extends]
    model_urls = model_info[:model_urls]

    # Scrape each model page for their ActiveRecord assocations
    all_relationships = GetModelAssociations.run(model_urls)

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

  def show_repo_controllers

    #Find all the controller URLs
    new_start_url = params[:start_url] + '/tree/master/app/controllers'

    #Make sure URL exists
    if (!url_exist?(new_start_url))
      flash[:alert] = "An invalid URL was entered"
      redirect_to :root
      return
    end
    
    directory_urls = ScrapeAllUrls.run(new_start_url)
    controller_urls = GetControllerUrls.run(directory_urls)

    #{controller => array of actions}
    @controllers = GetControllerActions.run(controller_urls)

    #Create a graph for each controller 
    @controllers.each do |name, actions|
      CreateControllerGraph.run(name, actions)
    end

  end

end
