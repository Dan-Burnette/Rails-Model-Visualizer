document.addEventListener('DOMContentLoaded', function() {
  initModelTableTooltips();
  initSVGZooming();
});

function initModelTableTooltips() {
  const modelNodes = document.querySelectorAll('.node');
  modelNodes.forEach(node => {
    const modelName = node.querySelector('title').textContent;
    const tableDataNode = document.getElementById(modelName);
    const content = tableDataNode
      ? tableDataNode.innerHTML
      : 'This model has no table';

    tippy(node, {
      allowHTML: true,
      content: sanitizeHtml(content),
      placement: 'auto',
      theme: 'custom',
    });
  });
}

// For large sized visualizations
function initSVGZooming() {
  console.log('init svg zoom');
  const graph = document.querySelector('.model-graph svg');
  const panZoomInstance = svgPanZoom(graph, {
    zoomEnabled: true,
    controlIconsEnabled: true,
    fit: true,
    center: true,
    minZoom: 0.1,
  });

  // zoom out
  // panZoomInstance.zoom(0.2);

  console.log('panZoomInstance', panZoomInstance);
}
