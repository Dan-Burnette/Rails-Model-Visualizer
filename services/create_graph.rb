require "active_support/inflector"

class CreateGraph < ApplicationService

  def initialize(title, models_to_associations)
    @title = title
    @models = models_to_associations.keys
    @associations = models_to_associations.values
    @graph = GraphViz.new(:G, :type => :digraph )
  end

  def call
    { nodes: nodes, links: links }.to_json
  end

  def nodes
    @models.each_with_index.map { |model, i| { id: i+1, name: model } }
  end

  def links
    @associations.flatten.map do |association|
      {
        source: find_node_id(association.from_model),
        target: find_node_id(association.to_model)
      }
    end
  end

  def find_node_id(model)
    node = nodes.find { |n| n[:name] == model }
    node[:id]
  end

  # def call
  #   set_graph_title
  #
  #   @models.each_with_index do |model, i|
  #     associations = @associations[i]
  #     create_association_edges(model, associations)
  #   end
  #
  #   @graph.output(:svg => "public/images/graph.svg")
  # end

  private

  # def set_graph_title
  #   @graph[:label] = "< <FONT POINT-SIZE='80'>" + "#{@title}" + "</FONT> >"
  # end
  #
  # def create_association_edges(model, associations)
  #   associations.each do |association|
  #     edge = @graph.add_edges(model, association.to_model)
  #
  #     label = "#{association.type}"
  #     if association.through_model
  #       edge[:style] = "dashed"
  #       label += " #{association.to_model} through #{association.through_model.pluralize}"
  #     end
  #
  #     edge[:label] = label
  #     edge[:fontsize] = 10
  #   end
  # end

  ####
  #


end
