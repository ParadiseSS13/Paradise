/datum/keybinding/client

/datum/keybinding/client/admin_help
	name = "Admin Help"
	keys = list("F1")

/datum/keybinding/client/admin_help/down(client/C)
	. = ..()
	C.adminhelp()

/datum/keybinding/client/toggle_fullscreen
	name ="Toggle Fullscreen"
	keys = list("F11")

/datum/keybinding/client/toggle_fullscreen/down(client/C)
	. = ..()
	C.toggle_fullscreen()

/datum/keybinding/client/toggle_min_hud
	name = "Toggle Minimal HUD"
	keys = list("F12")

/datum/keybinding/client/toggle_min_hud/down(client/C)
	. = ..()
	C.mob.hide_hud()
