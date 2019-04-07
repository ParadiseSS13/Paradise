/mob/living/silicon/robot/Login()
	..()
	regenerate_icons()
	show_laws(0)

	var/datum/hotkey_mode/cyborg/C = new(src)
	C.set_winset_values()
