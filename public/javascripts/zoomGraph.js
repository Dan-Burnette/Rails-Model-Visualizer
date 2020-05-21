document.addEventListener('DOMContentLoaded', function() {
  initSVGZooming();
});

function initSVGZooming() {
  const graph = document.querySelector('.model-graph svg');
  const panZoomInstance = svgPanZoom(graph, {
    zoomEnabled: true,
    controlIconsEnabled: true,
    fit: true,
    center: true,
    minZoom: 0.1,
  });

  window.addEventListener('resize', function() {
    panZoomInstance.resize(); // update SVG cached size and controls positions
    panZoomInstance.fit();
    panZoomInstance.center();
  });
}
