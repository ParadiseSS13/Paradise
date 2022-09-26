#define CMAG_CLEANTIME 50 //The cleaning time for cmagged objects is locked to this, for balance reasons


//For handling standard click-to-clean items like soap and mops.

//text_verb and text_description carry strings that, when pieced together by this proc, make the cleaning messages.
//text_verb is the verb that'll be used for cleaning, i.e. "User begins to [mop] the floor."
//text_description by default appends the name of the cleaning object to the cleaning message, i.e. "User begins to clean the floor[ with soap.]"
//If text_description is ".", the sentence will end early (so you don't say "Lusty Xenomorph Maid begins to clean the floor with the Lusty Xenomorph Maid")

/atom/proc/cleaning_act(mob/user, atom/cleaner, cleanspeed = 50, text_verb = "clean", text_description = " with [cleaner].")
	var/is_cmagged = FALSE

	if(user.client && (src in user.client.screen)) //You can't clean items you're wearing for technical reasons
		to_chat(user, "<span class='notice'>You need to take that [name] off before cleaning it.</span>")
		return FALSE

	if(HAS_TRAIT(src, TRAIT_CMAGGED)) //So we don't need a cleaning_act for every cmaggable object
		is_cmagged = TRUE
		text_verb = "clean the ooze off"
		cleanspeed = CMAG_CLEANTIME

	user.visible_message("<span class='warning'>[user] begins to [text_verb] \the [name][text_description]</span>")
	if(!do_after(user, cleanspeed, target = src) && src)
		return FALSE

	cleaner.post_clean(src, user)

	if(!cleaner.can_clean())
		return FALSE

	user.visible_message("<span class='notice'>You [text_verb] \the [name][text_description]</span>")

	if(is_cmagged) //If we've cleaned a cmagged object
		REMOVE_TRAIT(src, TRAIT_CMAGGED, "clown_emag")
		return TRUE
	else
		//Generic cleaning functionality
		var/obj/effect/decal/cleanable/C = locate() in src
		qdel(C)
		clean_blood()
		return TRUE

/turf/simulated/proc/clean_turf(mob/user, atom/cleaner)
	if(cleaner.can_clean())
		clean_blood()
		for(var/obj/effect/O in src)
			if(O.is_cleanable())
				qdel(O)

/atom/proc/can_clean() //For determining if a cleaning object can actually remove decals
	return FALSE

/atom/proc/post_clean(atom/target, mob/user) //For specific cleaning object behaviors after cleaning, such as mops making floors slippery.
	return
