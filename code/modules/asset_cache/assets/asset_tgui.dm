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
		"fa-regular-400.eot" = 'html/font-awesome/webfonts/fa-regular-400.eot',
		"fa-regular-400.woff" = 'html/font-awesome/webfonts/fa-regular-400.woff',
		"fa-solid-900.eot" = 'html/font-awesome/webfonts/fa-solid-900.eot',
		"fa-solid-900.woff" = 'html/font-awesome/webfonts/fa-solid-900.woff',
		"v4shim.css" = 'html/font-awesome/css/v4-shims.min.css'
	)
	parents = list(
		"font-awesome.css" = 'html/font-awesome/css/all.min.css'
	)
