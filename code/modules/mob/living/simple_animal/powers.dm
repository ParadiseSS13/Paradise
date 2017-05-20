/mob/living/simple_animal/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Animal"

	if(stat != CONSCIOUS)
		return

	if(layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		to_chat(src, text("<span class=notice'>You are now hiding.</span>"))
		for(var/mob/O in oviewers(src, null))
			if((O.client && !( O.blinded )))
				to_chat(O, text("<B>[] scurries to the ground!</B>", src))
	else
		layer = MOB_LAYER
		to_chat(src, text("<span class=notice'>You have stopped hiding.</span>"))
		for(var/mob/O in oviewers(src, null))
			if((O.client && !( O.blinded )))
				to_chat(O, text("[] slowly peaks up from the ground...", src))
