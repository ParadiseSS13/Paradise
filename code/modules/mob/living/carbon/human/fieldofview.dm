/datum/status_effect/fov
	id = "field of view" //Used for screen alerts. //The mob affected by the status effect.E //How many of the effect can be on one mob, and what happens when you try to add another
	var/obj/screen/fov/F
	var/mob/living/carbon/human/H

/datum/status_effect/fov/on_apply()
	. = ..()
	H = owner
	owner.hud_used.addfov(owner)
	F = H.client.screen.Find(/obj/screen/fov)

/mob/living/carbon/human
	var/fov

/datum/status_effect/fov/tick()
	. = ..()
	H = owner
	H.fov = H.hud_used.fov
	H.hud_used.fov.dir = H.dir
