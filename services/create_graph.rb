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
    @graph = GraphViz.new(:G, type: :digraph, label: graph_title)
  end

  def graph_title
    "< <FONT POINT-SIZE='80'>" + "#{@title}" + "</FONT> >"
  end

  def create_model_nodes
    @models.each do |model|
      @graph.add_nodes(model, label: model, style: "filled", color: "teal")
    end
  end

  def create_association_edges
    @associations.each do |association|
      @graph.add_edges(
        association.from_model,
        association.to_model,
        label: association.label,
        style: association.through_model ? "dashed" : "solid",
        fontsize: 10,
      )
    end
  end

  def output_graph
    @graph.output(svg: "public/images/graph.svg")
  end

end
