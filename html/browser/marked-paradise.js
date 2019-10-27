var $ = document.querySelector.bind(document);

function parse(node) {
  for (var i = 0; i < node.childNodes.length; i++) {
    parse(node.childNodes[i]);
  }

  if (!node.innerHTML || node.tagName === 'A') {
    return;
  }

  node.innerHTML = marked(node.innerHTML.replace(/<br>/gi, '\n').replace(/\t/gi, ''), { breaks: true, gfm: false });
}

window.onload = function() {
  var para = marked.Renderer.prototype.paragraph;
  var field = '<span class="paper_field">';
  marked.Renderer.prototype.paragraph = function(text) {
    if (text.slice(0, field.length) === field ||
        text.slice(0, 2) === '<a'||
        text.slice(0, 5) === '<font' && text.indexOf('<a') >= 0) {
      return text;
    }
    return para(text);
  };

  if ($('#markdown')) {
    parse($('#markdown'));
  }
}
