document.addEventListener('DOMContentLoaded', function() {
  initModelTableTooltips();
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
      placement: 'left',
      theme: 'custom',
    });
  });
}
