require_relative 'application_service'

class CreateGraph < ApplicationService
  def initialize(title, models_to_associations)
    @title = title
    @models = models_to_associations.keys
    @associations = models_to_associations.values.flatten
  end

  def call
    initialize_graph
    create_model_nodes
    create_association_edges
    output_graph
  end

  private

  def initialize_graph
    @graph =
      GraphViz.new(:G, type: :digraph, label: graph_title, fontname: font_name)
  end

  def graph_title
    "< <FONT POINT-SIZE='80'>" + "#{@title}" + '</FONT> >'
  end

  def create_model_nodes
    @models.each do |model|
      @graph.add_nodes(
        node_identifier(model),
        label: model, style: 'filled', color: '#FFA630', fontname: font_name
      )
    end
  end

  def create_association_edges
    @associations.each do |association|
      @graph.add_edges(
        node_identifier(association.from_model),
        node_identifier(association.to_model),
        label: association.label,
        style: association.through_model ? 'dashed' : 'solid',
        color: '#00a7e1',
        fontsize: 10,
        fontname: font_name
      )
    end
  end

  def output_graph
    @graph.output(svg: 'public/images/graph.svg')
  end

  def node_identifier(model)
    model_table_name(model)
  end

  def model_table_name(model)
    model.tableize
  end

  def font_name
    'Droid Sans Mono'
  end
end
