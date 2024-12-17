/datum/keybinding/living/pixel_shift
	keys = list("B")
	name = "Pixel Shift"
	category = KB_CATEGORY_MOVEMENT

/datum/keybinding/living/pixel_shift/down(client/user)
	. = ..()
	if(SEND_SIGNAL(user.mob, COMSIG_KB_MOB_PIXEL_SHIFT_DOWN) & COMSIG_KB_ACTIVATED)
		return
	user.mob.add_pixel_shift_component()

/datum/keybinding/living/pixel_shift/up(client/user)
	. = ..()
	SEND_SIGNAL(user.mob, COMSIG_KB_MOB_PIXEL_SHIFT_UP)
