/datum/asset/simple/namespaced/chess
	legacy = TRUE
	assets = list(
		"sprites.png" = 'icons/chess_pieces/sprites.png',
		"blank.gif" = 'icons/chess_pieces/blank.gif',
		"garbochess.js" = 'html/browser/garbochess.js',
	)
	parents = list(
		"boardui.js" = 'html/browser/boardui.js'
	)

/datum/asset/group/chess
	children = list(
		/datum/asset/simple/namespaced/chess,
		/datum/asset/simple/jquery
	)
