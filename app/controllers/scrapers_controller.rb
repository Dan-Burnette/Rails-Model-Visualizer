class ScrapersController < ApplicationController

  def index
  end

  def show_model_graph
    #Scrape for models ---------------------------------------
    start_url = params[:start_url] + '/tree/master/app/models'

    @raw = Wombat.crawl do
      base_url start_url
      data({css: ".css-truncate"}, :list)
    end

    @models = []
    @model_urls = []
    @raw_data = @raw["data"]

    #Process raw data into models and URLS to their pages
    @raw_data.each do |item|
      model_and_extension = item.split('.')
      if (model_and_extension.include?('rb'))
        model = model_and_extension[0]
        @models.push(model)
        model_url = start_url + '/' + model_and_extension.join('.')
        @model_urls.push(model_url)
      end
    end

    @all_lines = []
    @all_relationships = []
    
    #Scrape each model page for their activeRecord assocations
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
            relationships.push(line)
        end 
      end
      @all_relationships.push(relationships)
    end

    puts "BEFORE SLICING!!!!!!!!!!!!"
    puts "REL COUNT"
    puts @all_relationships.count
    @all_relationships.each do |r|
      puts r.inspect
    end


    #Schema Scraping Logic----------------------------------------------------
    schema_url = params[:start_url] + '/blob/master/db/schema.rb'
    raw_schema_page = Wombat.crawl do
      base_url schema_url
      data({css: ".js-file-line"}, :list)
    end

    @db_schema_data = raw_schema_page["data"]
    @db_schema_data.delete('end')
    @db_schema_data.delete("")
    @db_schema_data = @db_schema_data.select {|x| x.include?("add_index") == false }
    table_starts = @db_schema_data.each_index.select {|i| @db_schema_data[i].include?("create_table") }

    #Grabbing each table's data out
    @all_table_data = []
    @all_table_data_strs= []
    @model_to_data = {}
    table_starts.each_with_index do |x,i|
      first = x
      last = table_starts[i+1]
      if last
        table_data = @db_schema_data[first..last]
      else
        table_data = @db_schema_data[first...-1]
      end

      #make sure the table matches a model, otherwise we don't care about it
      model_name = table_data[0].split()[1].tr!('"', '')
      model_name = model_name.delete(',')
      model_name = model_name.singularize
  
      #remove the "create_table first element"
      table_data = table_data[1...-1]

      table_data_str = '<BR ALIGN="LEFT"/>'
      table_data.each do |d|
        table_data_str += d.to_s + '<BR ALIGN="LEFT"/>'
      end
      @all_table_data_strs.push(table_data_str)
      @all_table_data.push(table_data)
      @model_to_data.store(model_name, table_data_str)
     
      
    end
    puts table_starts.inspect
    puts table_starts.count

    puts @all_relationships.count
    puts "all relationships after"
    @all_relationships.each do |r|
      puts r.inspect 
    end
    
    #Graphing logic ---------------------------------------------------------
    @graph_title = params[:start_url].split('/')[-1]
    g = GraphViz.new(:G, :type => :digraph )
    g[:label] = "< <FONT POINT-SIZE='50'>" + "#{@graph_title}" + "</FONT> >"
    
    #Create a node for each model
    nodes = []
    models_and_attrs = []
    @models.each_with_index do |m,i|
      node = g.add_nodes(m)
      node[:label] = '<<b>' + "#{m}" + '</b> <br/>' + " #{@model_to_data[m]}" + '>'
      node[:shape => 'regular']
      nodes.push(node)
    end

    #Determine names of nodes already created (our non-plural models)
    nodeNames = []
    @models.each do |x|
      nodeNames.push(x)
    end
  
    #Connect the nodes with appropriately labeled edges
    nodes.each_with_index do |node, i|
      relationships = @all_relationships[i]
        
        puts relationships.inspect
        puts "NODE IS"
        puts nodeNames[i]
        puts "RELATIONSHIP IS======="
        puts @all_relationships[i]  
        if (relationships != nil )
          relationships.each do |r|
            relationship_parts = r.split(':', 2)
            relationship = relationship_parts[0] + '\n'
            nodeToConnect = relationship_parts[1].delete(':').delete(',')
            
            # processing for a "through" association
            if (nodeToConnect.include?("through"))
              if (nodeToConnect.include?("source"))
                join_model = nodeToConnect.split()[-4]
                relationship += "through #{join_model}"
                index = nodeNames.find_index(nodeToConnect.split()[-1])
              else 
                join_model = nodeToConnect.split()[-1]
                relationship += "through #{join_model}"
                index = nodeNames.find_index(nodeToConnect.split()[0].singularize) 
              end
              nodeToConnect = nodes[index]
              # puts "relationship"
              # puts relationship
              # puts "connecting"
              # puts nodeNames[i].inspect
              # puts "and"
              # puts nodeNames[index].inspect
              # puts 
            
            #processing for polymorphic "as" association
            elsif (nodeToConnect.include?("as"))
              relationship += nodeToConnect.split()[1..-1].join(" ")
              index = nodeNames.find_index(nodeToConnect.split()[0].singularize)
              nodeToConnect = nodes[index]
              # puts relationship
              # puts "connecting"
              # puts nodeNames[i].inspect
              # puts "and"
              # puts nodeNames[index].inspect
              # puts 

            #if plural find the singular model node
            elsif (nodeToConnect.singularize != nodeToConnect)
              index = nodeNames.find_index(nodeToConnect.singularize)
              nodeToConnect = nodes[index]

              # puts relationship
              # puts "connecting"
              # puts nodeNames[i].inspect
              # puts "and"
              # puts nodeNames[index].inspect
              # puts 

            #If it is singular, find that model node
            elsif (nodeNames.include?(nodeToConnect))
              index = nodeNames.find_index(nodeToConnect)
              nodeToConnect = nodes[index]

              # puts relationship
              # puts "connecting"
              # puts nodeNames[i].inspect
              # puts "and"
              # puts nodeNames[index].inspect
              # puts 
            else
              puts "WHAT GOT DOWN HERE"
              puts relationship
              puts nodeToConnect
            end

            edge = g.add_edges(node, nodeToConnect)

            edge[:label] =  "#{relationship}" 
            edge[:fontsize] = 10
          end
      end
    end

    #Output the graph
    g.output(:png => "app/assets/images/graph.png")

    #PDF Creation logic ---------------------------
    width = Dimensions.width("app/assets/images/graph.png")
    height = Dimensions.height("app/assets/images/graph.png")

    Prawn::Document.generate("public/#{@graph_title}.pdf", :page_size => [width+100, height+100]) do
      pic = "app/assets/images/graph.png"
      image(pic, :width => width, :height => height)
    end
  end

end
