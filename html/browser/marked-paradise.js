// Paradise-specific handling of marked.js.
// Basically we call it on element with id=markdown, and play with paragraphization a bit
// Requires marked.js to be loaded in order to be useful.

var $ = document.querySelector.bind(document);
function parse(node) {
	for (var i = 0; i < node.childNodes.length; i++) parse(node.childNodes[i]);

	if (!node.innerHTML) return;

	if (node.children.length == 0) {
		node.innerHTML = marked(node.innerHTML.replace(/<br>/gi, '\n').replace(/\t/gi, ''), { breaks: false, gfm: false });
		// marked.js wraps content into <p> tags, which is looks atrocious when we call it recursively.
		// The following line unwraps it.
		if (node.children.length == 1 && node.children[0].tagName == 'P') node.innerHTML = node.children[0].innerHTML;
	}
}

window.onload = function () {
	if ($('#markdown')) parse($('#markdown'));
};
