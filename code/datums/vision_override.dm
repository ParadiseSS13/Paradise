/datum/vision_override
	var/name = "vision override"
	var/see_in_dark = 0
	var/see_invisible = 0
	var/light_sensitive = 0
	var/sight_flags = 0
	var/pmaster_c_type = null
	var/pmaster_g_type = null

/datum/vision_override/nightvision
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM

/datum/vision_override/nightvision/thermals
	sight_flags = SEE_MOBS

/datum/vision_override/nightvision/thermals/ling_augmented_eyesight
	light_sensitive = 1

/datum/vision_override/nightvision/overbright
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LIVING
	pmaster_c_type = /obj/screen/fullscreen/pmaster_c_shadowling
	pmaster_g_type = /obj/screen/fullscreen/pmaster_g_shadowling