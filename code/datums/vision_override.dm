/datum/vision_override
	var/name = "vision override"

	var/sight_flags = 0
	var/see_in_dark = 0
	var/lighting_alpha

/datum/vision_override/nightvision
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
