/datum/keybinding/client/t_fullscreen
	name = "Переключить Fullscreen"
	keys = list("F11")

/datum/keybinding/client/t_fullscreen/down(client/C)
	. = ..()
	C.toggle_fullscreen()
