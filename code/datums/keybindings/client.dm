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
	keys = list("F2")

/datum/keybinding/client/ooc/down(client/C)
	. = ..()
	C.ooc()

/datum/keybinding/client/say
	name = "Say"
	keys = list("F3")

/datum/keybinding/client/say/down(client/C)
	. = ..()
	C.mob.say_wrapper()

/datum/keybinding/client/me
	name = "Me"
	keys = list("F4")

/datum/keybinding/client/me/down(client/C)
	. = ..()
	C.mob.me_wrapper()

/datum/keybinding/client/toggle_min_hud
	name = "Toggle Minimal HUD"
	keys = list("F12")

/datum/keybinding/client/toggle_min_hud/down(client/C)
	. = ..()
	C.mob.button_pressed_F12()
