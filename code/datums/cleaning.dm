//For handling standard click-to-clean items like soap and mops.

//text1, text2, and text3 carry strings that, when pieced together by this proc, make the cleaning messages.
//text1 and text2 pertain to the start message, i.e. "User begins to [clean] the floor[ with the mop.]"
//text3 pertains to the end message, i.e. "You [finished mopping] the floor."

/atom/proc/cleaning_act(mob/user, atom/cleaner, cleanspeed = 50, text1 = "clean", text2 = " with [cleaner].", text3 = "clean")
	var/cmag_cleantime = 50 //The cleaning time for cmagged objects is locked to this, for balance reasons

	if(user.client && (src in user.client.screen)) //You can't clean items you're wearing for technical reasons
		to_chat(user, "<span class='notice'>You need to take that [name] off before cleaning it.</span>")
		return FALSE

	if(HAS_TRAIT(src, TRAIT_CMAGGED)) //So we don't need a cleaning_act for every cmaggable object
		text1 = "clean the ooze off"
		text3 = "clean the ooze off"
		cleanspeed = cmag_cleantime

	user.visible_message("<span class='warning'>[user] begins to [text1] \the [name][text2]</span>")
	if(!do_after(user, cleanspeed, target = src) && src)
		return FALSE

	cleaner.post_clean(src, user)

	if(!cleaner.can_clean())
		return FALSE

	user.visible_message("<span class='notice'>You [text3] \the [name][text2]</span>")

	if(text3 == "clean the ooze off") //If we've cleaned a cmagged object
		REMOVE_TRAIT(src, TRAIT_CMAGGED, "clown_emag")
		return TRUE

	else
		//Generic cleaning functionality
		var/obj/effect/decal/cleanable/C = locate() in src
		qdel(C)
		src.clean_blood()
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
