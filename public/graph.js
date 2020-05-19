console.log('graph js loaded!');

document.addEventListener('DOMContentLoaded', function() {
  createGraph();
});

function createGraph() {
  // set the dimensions and margins of the graph
  var margin = {top: 10, right: 30, bottom: 30, left: 40},
    width = window.innerWidth - margin.left - margin.right,
    height = window.innerWidth - margin.top - margin.bottom;

  // append the svg object to the body of the page
  var svg = d3
    .select('#graph')
    .append('svg')
    .attr('width', width + margin.left + margin.right)
    .attr('height', height + margin.top + margin.bottom)
    .append('g')
    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

  const data = JSON.parse(document.getElementById('graph').dataset.graph);
  const {nodes, links} = data;

  console.log('links', links);
  console.log('nodes', nodes);

  // Let's list the force we wanna apply on the network
  var simulation = d3
    .forceSimulation(nodes) // Force algorithm is applied to data.nodes
    .force(
      'link',
      d3
        .forceLink() // This force provides links between nodes
        .id(function(d) {
          return d.id;
        }) // This provide  the id of a node
        .links(links), // and this the list of links
    )
    .force('charge', d3.forceManyBody().strength(-400)) // This adds repulsion between nodes. Play with the -400 for the repulsion strength
    .force('center', d3.forceCenter(width / 2, height / 2)) // This force attracts nodes to the center of the svg area
    .on('end', ticked);

  // This function is run at each iteration of the force algorithm, updating the nodes position.
  function ticked() {
    link
      .attr('x1', function(d) {
        return d.source.x;
      })
      .attr('y1', function(d) {
        return d.source.y;
      })
      .attr('x2', function(d) {
        return d.target.x;
      })
      .attr('y2', function(d) {
        return d.target.y;
      });

    node
      .attr('cx', function(d) {
        return d.x + 6;
      })
      .attr('cy', function(d) {
        return d.y - 6;
      });
  }

  // Initialize the links
  var link = svg
    .selectAll('line')
    .data(links)
    .enter()
    .append('line')
    .style('stroke', '#aaa');

  // Initialize the nodes
  var node = svg
    .selectAll('circle')
    .data(nodes)
    .enter()
    .append('circle')
    .attr('r', 100)
    .style('fill', '#69b3a2')
    .call(simulation.drag);
}
