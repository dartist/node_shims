library js;

escapeHtml(html) => "$html"
  .replaceAll("&", '&amp;')
  .replaceAll("<", '&lt;')
  .replaceAll(">", '&gt;')
  .replaceAll('"', '&quot;');
