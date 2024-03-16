/datum/asset/simple/tgui
	keep_local_name = TRUE
	assets = list(
		"tgui.bundle.js" = 'tgui/public/tgui.bundle.js',
		"tgui.bundle.css" = 'tgui/public/tgui.bundle.css'
)

/datum/asset/simple/tgui_panel
	keep_local_name = TRUE
	assets = list(
		"tgui-panel.bundle.js" = 'tgui/public/tgui-panel.bundle.js',
		"tgui-panel.bundle.css" = 'tgui/public/tgui-panel.bundle.css',
	)

/datum/asset/simple/namespaced/fontawesome
	legacy = TRUE
	assets = list(
		"fa-brands-400.ttf" = 'html/font-awesome/webfonts/fa-brands-400.ttf',
		"fa-solid-900.ttf" = 'html/font-awesome/webfonts/fa-solid-900.ttf',
		"fa-regular-400.ttf" = 'html/font-awesome/webfonts/fa-regular-400.ttf',
		"fa-v4compatibility.ttf" = 'html/font-awesome/webfonts/fa-v4compatibility.ttf',
		"v4shim.css" = 'html/font-awesome/css/v4-shims.min.css'
	)
	parents = list(
		"font-awesome.css" = 'html/font-awesome/css/all.min.css'
	)
