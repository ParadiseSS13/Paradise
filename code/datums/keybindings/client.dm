/datum/keybinding/client
	category = KB_CATEGORY_UNSORTED

/datum/keybinding/client/admin_help
	name = "Admin Help"
	keys = list("F1")

/datum/keybinding/client/admin_help/down(client/C)
	. = ..()
	C.adminhelp()

/datum/keybinding/client/ooc
	name = "OOC"
	keys = list("F2", "O")

/datum/keybinding/client/ooc/down(client/C)
	. = ..()
	C.ooc()

/datum/keybinding/client/looc
	name = "Локальный OOC"
	keys = list("L")

/datum/keybinding/client/looc/down(client/C)
	. = ..()
	C.looc()

/datum/keybinding/client/say
	name = "Say"
	keys = list("F3", "T")

/datum/keybinding/client/say/down(client/C)
	. = ..()
	C.mob.say_wrapper()

/datum/keybinding/client/me
	name = "Me"
	keys = list("F4", "M")

/datum/keybinding/client/me/down(client/C)
	. = ..()
	C.mob.me_wrapper()

/datum/keybinding/client/t_fullscreen
	name = "Переключить Fullscreen"
	keys = list("F11")

/datum/keybinding/client/t_fullscreen/down(client/C)
	. = ..()
	C.toggle_fullscreen()

/datum/keybinding/client/toggle_min_hud
	name = "Переключить минимальный HUD"
	keys = list("F12")

/datum/keybinding/client/toggle_min_hud/down(client/C)
	. = ..()
	C.mob.button_pressed_F12()
