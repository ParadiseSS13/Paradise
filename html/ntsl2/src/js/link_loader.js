var $ = require("../node_modules/jquery/dist/jquery.min.js");

module.exports.reload = function () {
	$(".linkActive")
		.off("click")
		.on("click", function (event) {
			event.preventDefault();
			var href = $(this).data("href");
			if (href) {
				href = window.byondSrc + href;
				window.location.href = href;
			}
		})
};