require "active_support/inflector"

class CreateGraph < ApplicationService

  def initialize(title, models_to_associations)
    @title = title
    @models = models_to_associations.keys
    @associations = models_to_associations.values
    @graph = GraphViz.new(:G, :type => :digraph )
  end

  def call
    puts "MODELS ARE"
    puts @models.inspect
    set_graph_title

    nodes = create_model_nodes

    nodes.each_with_index do |node, i|
      associations = @associations[i]
      create_association_edges(node, associations)
    end

    @graph.output(:svg => "public/images/graph.svg")
  end

  def set_graph_title
    @graph[:label] = "< <FONT POINT-SIZE='80'>" + "#{@title}" + "</FONT> >"
  end

  def create_model_nodes
    @models.inject([]) do |nodes, model|
      node = @graph.add_nodes(model)
      node[:label] = "#{model}" 
      node[:style => 'filled']
      node[:fillcolor => "teal"]
      nodes << node
    end
  end

  def create_association_edges(node, associations)
    associations.each do |association|
      puts "association is"
      puts association.inspect
      # dotted_edge = false
      # nodes_involved_raw = 
      #   r.split(" ").select do |x|
      #     @models.include?( "#{x}".delete(':').delete(',').delete("'").delete('"').tableize.singularize.downcase) 
      #   end
      # nodes_involved = []
      # nodes_involved_raw.each do |n|
      #   n = n.delete(':').delete(',').delete("'").delete('"').tableize.singularize.downcase
      #   nodes_involved.push(n)
      # end

      # The standard processing
      # association_parts  = r.split(':', 2)
      # association = association_parts[0] + '\n'
      # other_parts = association_parts[1]

      # If only one node is found, it is the one we want to connect to
      # if (nodes_involved.size == 1)
      #   nodeToConnect = nodes_involved[0]

        # If two nodes are found
      # elsif (nodes_involved.size == 2)
      #   dotted_edge = true
      #   if (r.include?("source") && r.include?("through"))
      #     join_model = nodes_involved[0].pluralize
      #     nodeToConnect = nodes_involved[1]
      #     association += "through #{join_model}"
      #   elsif (r.include?("through"))
      #     join_model = nodes_involved[1].pluralize
      #     nodeToConnect = nodes_involved[0]
      #     association += "through #{join_model}"
      #   elsif (r.include?("include"))
      #     nodeToConnect = nodes_involved[0]
      #     #Possible unaccounted for things here...?
      #   else 
      #     nodeToConnect = nodes_involved[0]
      #   end
      #
      # else
      #   nodeToConnect = other_parts
      # end

      edge = @graph.add_edges(node, association.to_model)

      label = "#{association.type}"
      if association.through_model
        edge[:style] = "dashed"
        label += " #{association.to_model} through #{association.through_model.pluralize}"
      end

      edge[:label] = label
      edge[:fontsize] = 10

    end
  end

end
