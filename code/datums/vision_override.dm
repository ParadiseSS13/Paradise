/datum/vision_override
	var/name = "vision override"

	var/sight_flags = 0
	var/see_in_dark = 0
	var/lighting_alpha
	
	var/light_sensitive = 0

/datum/vision_override/nightvision
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

/datum/vision_override/nightvision/thermals
	sight_flags = SEE_MOBS

/datum/vision_override/nightvision/thermals/ling_augmented_eyesight
	light_sensitive = 1
