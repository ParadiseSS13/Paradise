/datum/status_effect/fov
	id = "field of view" //Used for screen alerts. //The mob affected by the status effect.E //How many of the effect can be on one mob, and what happens when you try to add another
	var/obj/screen/fov/F
	var/mob/living/carbon/human/H

/datum/status_effect/fov/on_apply()
	. = ..()
	H = owner
	H.client.screen.Add(/obj/screen/fov,H.client.screen.len)


/mob/living/carbon/human
	var/fov

/datum/status_effect/fov/tick()
	. = ..()
	H = owner
	if(!H.fov)
		H.fov = H.hud_used.fov
