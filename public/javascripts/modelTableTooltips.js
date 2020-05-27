document.addEventListener('DOMContentLoaded', function() {
  initModelTableTooltips();
});

function initModelTableTooltips() {
  const modelNodes = document.querySelectorAll('.node');
  modelNodes.forEach(node => {
    const tableName = node.querySelector('title').textContent;
    const tableDataNode = document.getElementById(tableName);
    const content = tableDataNode
      ? tableDataNode.innerHTML
      : "Couldn't find table for this model.";

    tippy(node, {
      allowHTML: true,
      content: sanitizeHtml(content),
      placement: 'auto',
      theme: 'custom',
    });
  });
}
