document.addEventListener('DOMContentLoaded', function() {
  initLoader();
  initModelTableTooltips();
});

function initLoader() {
  const form = document.querySelector('form');
  form.addEventListener('submit', showLoader);
}

function hideNonLoaderElements() {
  const stuffToHide = document.querySelectorAll(
    '.form-container, .examples, .source, .contact',
  );
  stuffToHide.forEach(e => (e.style.display = 'none'));
}

function showLoader() {
  hideNonLoaderElements();
  const loader = document.getElementById('loader');
  loader.style.display = 'block';
}

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
