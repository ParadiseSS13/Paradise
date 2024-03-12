/mob/proc/add_pixel_shift_component()
	return

/mob/living/add_pixel_shift_component()
	AddComponent(/datum/component/pixel_shift)

/mob/living/silicon/ai/add_pixel_shift_component()
	return

/datum/species/moth/spec_Process_Spacemove(mob/living/carbon/human/H)
	. = ..()
	if(has_gravity(H))
		return FALSE
