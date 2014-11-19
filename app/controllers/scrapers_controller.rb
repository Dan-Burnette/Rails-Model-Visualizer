class ScrapersController < ApplicationController
  require "net/http"

  def show_model_graph
    # Scrape for models and their URLS ---------------------------------------
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
      #Filter out bad relationships
      lines.each do |line|
        line_split = line.split(' ')
        #eliminating lines such as "attachment_fake_belongs_to_group(a)"
        #23 is the length of has_and_belongs_to_many, the biggest relationship
        if (line_split[0] != nil && line_split[0].length <= 23)
          if (line_split[0].include?("belongs_to") || line_split[0].include?("has_one") ||
              line_split[0].include?("has_many") || line_split[0].include?("belongs_to"))
            if (!line.include?("validates") && !line.include?('#'))
              relationships.push(line)
            end
          end 
        end
      end
      @all_relationships.push(relationships)
    end

    # Schema Scraping Logic-----------------------------
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
  

  def show_model_graph_laravel
    # Scrape for models and their URLS ---------------------------------------
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
    get_models_and_urls_laravel(@directory_urls)

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
      #Filter out bad relationships
      lines.each do |line|
        line_split = line.split(' ')
        #eliminating lines such as "attachment_fake_belongs_to_group(a)"
        #23 is the length of has_and_belongs_to_many, the biggest relationship
        if (line_split[1] != nil)
          if (line_split[1].include?("belongsTo") || line_split[1].include?("hasOne") ||
              line_split[1].include?("hasMany") || line_split[1].include?("belongsTo"))
            if (!line.include?("validates") && !line.include?('#'))
              relationships.push(line)
            end
          end 
        end
      end
      @all_relationships.push(relationships)
    end

    # Schema Scraping Logic-----------------------------
    # schema_url = params[:start_url] + '/blob/master/db/schema.rb'
    # if (url_exist?(schema_url))
    #   raw_schema_page = Wombat.crawl do
    #     base_url schema_url
    #     data({css: ".js-file-line"}, :list)
    #   end

    #   @db_schema_data = raw_schema_page["data"]
    #   @db_schema_data.delete('end')
    #   @db_schema_data.delete("")
    #   #remove the lines with add index, we don't want unneeded details like that
    #   @db_schema_data = @db_schema_data.select {|x| x.include?("add_index") == false }

    #   #Find the indecies of where each table starts
    #   table_starts = @db_schema_data.each_index.select {|i| @db_schema_data[i].include?("create_table")}

    #   #Grabbing each table's data out
    #   @all_table_data = []
    #   @all_table_data_strs= []
    #   @model_to_data = {}
    #   table_starts.each_with_index do |x,i|
    #     first = x
    #     last = table_starts[i+1]
    #     if last
    #       table_data = @db_schema_data[first...last]
    #     else
    #       table_data = @db_schema_data[first..-1]
    #     end

    #     model_name = table_data[0].split()[1].tr!('"', '')
    #     model_name = model_name.delete(',')
    #     model_name = model_name.singularize
    
    #     #remove the "create_table first element"
    #     table_data = table_data[1..-1]

    #     table_data_str = '<b>Schema</b><br/>'
    #     table_data.each do |d|
    #       table_data_str += d.to_s + '<br/>'
    #       table_data_str.gsub! /"/, ' '
    #     end
    #     @all_table_data_strs.push(table_data_str)
    #     @all_table_data.push(table_data)
    #     @model_to_data.store(model_name, table_data_str)
    #   end
    # else
    #   redirect_to :root
    #   flash[:alert] = "That project doesn't have a DB schema file! Not going to work...try another!"
    #   return
    # end

    # Classes that extend classes which extend activeRecord base must also have their schemas
    # populated with the schema of the class they extend
    # @model_to_model_it_extends.each do |model, extends|
    #   data = @model_to_data[extends]
    #   @model_to_data.store(model, data)
    # end

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
        if (relationships != nil)
          relationships.each do |r|
            dotted_edge = false
            
            # The standard processing
            puts "relationship--------------"
            puts r
            nodes_involved = r.split("(")[1].split(" ")[0].gsub!(/\W+/, '').downcase
            relationship =  r.split("(")[0].split("->")[-1] + '\n'
            puts "Node to Connect ----- AND ---- RELATIONSHIP"
            puts nodeToConnect.inspect
            puts relationship.inspect
            edge = g.add_edges(node, nodeToConnect)
            edge[:label] =  "#{relationship}" 
            edge[:fontsize] = 10

            if (dotted_edge)
              edge[:style] = "dashed"
            end

          end
      end
    end

  end

end
