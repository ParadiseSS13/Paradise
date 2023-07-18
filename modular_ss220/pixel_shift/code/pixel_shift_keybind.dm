/datum/keybinding/living/pixel_shift
	keys = list("B")
	name = "Pixel Shift"
	category = KB_CATEGORY_MOVEMENT

/datum/keybinding/living/pixel_shift/down(client/user)
	. = ..()
	SEND_SIGNAL(user.mob, COMSIG_MOB_PIXEL_SHIFT_KEYBIND, TRUE)

/datum/keybinding/living/pixel_shift/up(client/user)
	. = ..()
	SEND_SIGNAL(user.mob, COMSIG_MOB_PIXEL_SHIFT_KEYBIND, FALSE)
