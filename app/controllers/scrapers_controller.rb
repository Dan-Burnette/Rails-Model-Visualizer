class ScrapersController < ApplicationController
  require "net/http"

  def show_all
    show_model_graph
    show_repo_controllers
  end

  def show_model_graph
    # Scrape for models and their URLS 
    @directory_urls = []
    @models = []
    @models_that_extend_active_record_base = []
    @model_to_model_it_extends = {}
    @model_urls = []

    # Initial is githubprojecturl/tree/master/app
    new_start_url = params[:start_url] + '/tree/master/app/models'
    #Make sure URL is valid
    if (!url_exist?(new_start_url))
      flash[:alert] = "An invalid URL was entered"
      redirect_to :root
      return
    end

    # Go through all directories recursively and grab the URLS for each file,
    # pushing them into @directory_urls
    scrape_all_urls(new_start_url)
    # From these URLS, find the models and their URLs, pushing them into @model_urls
    get_models_and_urls(@directory_urls)

    # Scrape each model page for their ActiveRecord assocations
    @all_relationships = []
    @model_urls.each do |url|
      relationships = GetModelAssociations.run(url)
      @all_relationships.push(relationships)
    end

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

    # Graphing logic -------------------------------------------------------
    #///////////////////////////////////////////////////////////////////////

    @graph_title = params[:start_url].split('/')[-1]
    g = GraphViz.new(:G, :type => :digraph )
    g[:label] = "< <FONT POINT-SIZE='80'>" + "#{@graph_title}" + "</FONT> >"

    # Create a node for each model
    nodes = []
    models_and_attrs = []
    @models.each do |m|
      node = g.add_nodes(m)
      node[:label] = "#{m}" 
      node[:style => 'filled']
      node[:fillcolor => "teal"]
      nodes.push(node)
    end
    
    # Determine names of nodes created (all the models)
    nodeNames = []
    @models.each do |x|
      nodeNames.push(x)
    end
  
    # Connect the nodes with appropriately labeled edges
    nodes.each_with_index do |node, i|
      relationships = @all_relationships[i]
        if (relationships != nil )
          relationships.each do |r|
            dotted_edge = false
            nodes_involved_raw = 
            r.split(" ").select do |x|
               nodeNames.include?( "#{x}".delete(':').delete(',').delete("'").delete('"').tableize.singularize.downcase) 
            end
            nodes_involved = []
            nodes_involved_raw.each do |n|
              n = n.delete(':').delete(',').delete("'").delete('"').tableize.singularize.downcase
              nodes_involved.push(n)
            end

            # The standard processing
            relationship_parts  = r.split(':', 2)
            relationship = relationship_parts[0] + '\n'
            other_parts = relationship_parts[1]
            
            #If only one node is found, it is the one we want to connect to
            if (nodes_involved.size == 1)
              nodeToConnect = nodes_involved[0]

            #If two nodes are found
            elsif (nodes_involved.size == 2)
              dotted_edge = true
              if (r.include?("source") && r.include?("through"))
                join_model = nodes_involved[0].pluralize
                nodeToConnect = nodes_involved[1]
                relationship += "through #{join_model}"
              elsif (r.include?("through"))
                join_model = nodes_involved[1].pluralize
                nodeToConnect = nodes_involved[0]
                relationship += "through #{join_model}"
              elsif (r.include?("include"))
                nodeToConnect = nodes_involved[0]
              #Possible unaccounted for things here...?
              else 
                nodeToConnect = nodes_involved[0]
              end
              
            else
              nodeToConnect = other_parts
            end

            edge = g.add_edges(node, nodeToConnect)
            edge[:label] =  "#{relationship}" 
            edge[:fontsize] = 10

            if (dotted_edge)
              edge[:style] = "dashed"
            end

          end
      end
    end

    #Output the graph
    g.output(:svg => "app/assets/images/graph.svg")

  end

  def show_repo_controllers

    #Find all the controller URLs
    new_start_url = params[:start_url] + '/tree/master/app/controllers'
    @directory_urls = []
    scrape_all_urls(new_start_url)
    @controller_urls = get_controller_urls(@directory_urls)

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
