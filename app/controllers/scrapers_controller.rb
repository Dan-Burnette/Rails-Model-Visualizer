class ScrapersController < ApplicationController
  require "net/http"

  def show_model_graph
    # Scrape for models and their URLS ---------------------------------------
    @directory_urls = []
    @models = []
    @model_urls = []

    # Initial is githubprojecturl/tree/master/app
    new_start_url = params[:start_url] + '/tree/master/app/models'
    # Go through all directories recursively and grab the URLS for each file,
    # pushing them into @directory_urls
    scrape_all_urls(new_start_url)
    # From these URLS, find the models and their URLs, pushing them into @model_urls
    get_models_and_urls(@directory_urls)

    # Scrape each model page for their ActiveRecord assocations
    @all_lines = []
    @all_relationships = []
    @model_urls.each do |url|
      lines = Wombat.crawl do 
        base_url url
        data({css: ".js-file-line"}, :list)
      end

      lines = lines["data"]
      @all_lines.push(lines)

      relationships = []
      lines.each do |line|
        if (line.include?("belongs_to") || line.include?("has_one") ||
            line.include?("has_many") || line.include?("belongs_to"))
          if (line.include?("validates") == false)
            relationships.push(line)
          end
        end 
      end
      @all_relationships.push(relationships)
    end

    # Schema Scraping Logic----------------------------------------------------
    schema_url = params[:start_url] + '/blob/master/db/schema.rb'
    if (url_exist?(schema_url))
      raw_schema_page = Wombat.crawl do
        base_url schema_url
        data({css: ".js-file-line"}, :list)
      end

      @db_schema_data = raw_schema_page["data"]
      @db_schema_data.delete('end')
      @db_schema_data.delete("")
      #remove the lines with add index, we don't want unneeded details like that
      @db_schema_data = @db_schema_data.select {|x| x.include?("add_index") == false }
      #Find the indecies of where each table starts
      table_starts = @db_schema_data.each_index.select {|i| @db_schema_data[i].include?("create_table")}

      #Grabbing each table's data out
      @all_table_data = []
      @all_table_data_strs= []
      @model_to_data = {}
      table_starts.each_with_index do |x,i|
        first = x
        last = table_starts[i+1]
        if last
          table_data = @db_schema_data[first...last]
        else
          table_data = @db_schema_data[first..-1]
        end

        model_name = table_data[0].split()[1].tr!('"', '')
        model_name = model_name.delete(',')
        model_name = model_name.singularize
    
        #remove the "create_table first element"
        table_data = table_data[1..-1]

        table_data_str = '<b>Schema</b><br/>'
        table_data.each do |d|
          table_data_str += d.to_s + '<br/>'
          table_data_str.gsub! /"/, ' '
        end
        @all_table_data_strs.push(table_data_str)
        @all_table_data.push(table_data)
        @model_to_data.store(model_name, table_data_str)
      end
    end

      # Graphing logic -------------------------------------------------
      @graph_title = params[:start_url].split('/')[-1]
      g = GraphViz.new(:G, :type => :digraph )
      g[:label] = "< <FONT POINT-SIZE='80'>" + "#{@graph_title}" + "</FONT> >"

      # Create a node for each model
      nodes = []
      models_and_attrs = []
      @models.each do |m|
        node = g.add_nodes(m)
        node[:label] = '<<b>' + "#{m}" + '</b> <br/> >'
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
    puts "models"
    puts @models.inspect

    nodes.each_with_index do |node, i|
      dotted_edge = false
      relationships = @all_relationships[i]
        if (relationships != nil )
          relationships.each do |r|
            #Refactor ATTEMPT----------------------------------------------
            puts "relationship is -------"
            puts r
            nodes_involved_raw = 
            r.split(" ").select do |x|
               nodeNames.include?( "#{x}".delete(':').delete(',').delete("'").singularize.downcase) 
            end
            nodes_involved = []
            nodes_involved_raw.each do |n|
              n = n.delete(':').delete(',').singularize.downcase
              nodes_involved.push(n)
            end
            puts "nodes_involved"
            puts nodes_involved.inspect

            #---------------------------------------------------------------------
            # The standard processing
            relationship = r.split(':', 2)[0] + '\n'
            
            #If only one node is found, it is the one we want to connect to
            if (nodes_involved.size == 1)
              nodeToConnect = nodes_involved[0]

            #If two nodes are found, there must be a "through" relationship going on
            elsif (nodes_involved.size == 2)
              dotted_edge = true
              if (r.include?("source") && r.include?("through"))
                join_model = nodes_involved[0].pluralize
                nodeToConnect = nodes_involved[1]
              elsif (r.include?("through"))
                join_model = nodes_involved[1].pluralize
                nodeToConnect = nodes_involved[0]
              end
              relationship += "through #{join_model}"
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

end
