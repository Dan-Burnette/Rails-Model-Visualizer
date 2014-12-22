class CreateControllerGraph

  def self.run(name, actions)

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