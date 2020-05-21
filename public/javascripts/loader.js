document.addEventListener('DOMContentLoaded', function() {
  console.log("loader script");
  initLoader();
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
