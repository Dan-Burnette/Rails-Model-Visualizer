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
    puts table_starts.inspect

    #Grabbing each table's data out
    @all_table_data = []
    @all_table_data_strs= []
    table_starts.each_with_index do |x,i|
      first = x
      last = table_starts[i+1]
      if last
        table_data = @db_schema_data[first..last]
      else
        table_data = @db_schema_data[first...-1]
      end
      #remove the "create_table first element"
      table_data = table_data[1..-1]
      table_data_str = ""
      table_data.each do |d|
        table_data_str += d.to_s + '\n'
      end
      @all_table_data_strs.push(table_data_str)
      @all_table_data.push(table_data)
    end
    

    #Graphing logic ---------------------------------------------------------
    g = GraphViz.new(:G, :type => :digraph )
    #Create a node for each model
    nodes = []
    @models.each_with_index do |m,i|
      model_and_attrs = "#{m}" + "#{@all_table_data_strs[i]}"
      node = g.add_nodes(model_and_attrs)
      node[:shape => 'regular']
      node[:size => 0.20]
      node[:fontsize => 10]
      nodes.push(node)
    end

      #Generating appropriate edges
      nodes.each_with_index do |node, i|
        relationships = @all_relationships[i]
        puts relationships.inspect
        relationships.each do |r|
          relationship_parts = r.split(':', 2)
          relationship = relationship_parts[0]
          nodeToConnect = relationship_parts[1].delete(':')
          edge = g.add_edges(node, nodeToConnect)
          edge[:label => relationship]
        end
      end
      g.output(:png => "app/assets/images/test.png")
  end


  
end
