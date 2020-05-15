class CreateGraph

  def self.run(information)
    graph_title = information[:graph_title]
    models = information[:models]
    all_relationships = information[:all_relationships]

    g = GraphViz.new(:G, :type => :digraph )
    g[:label] = "< <FONT POINT-SIZE='80'>" + "#{graph_title}" + "</FONT> >"

    # Create a node for each model
    nodes = []
    models_and_attrs = []
    models.each do |m|
      node = g.add_nodes(m)
      node[:label] = "#{m}" 
      node[:style => 'filled']
      node[:fillcolor => "teal"]
      nodes.push(node)
    end

    # Determine names of nodes created (all the models)
    nodeNames = []
    models.each do |x|
      nodeNames.push(x)
    end

    # Connect the nodes with appropriately labeled edges
    nodes.each_with_index do |node, i|
      relationships = all_relationships[i]
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
    g.output(:svg => "public/images/graph.svg")
  end

end
