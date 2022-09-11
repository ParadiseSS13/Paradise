//For handling standard click-to-clean items like soap and mops.

//text1, text2, and text3 carry strings that, when pieced together by this proc, make the cleaning messages.
//text1 and text2 pertain to the start message, i.e. "User begins to [clean] the floor[ with the mop.]"
//text3 pertains to the end message, i.e. "You [finished mopping] the floor."

/atom/proc/cleaning_act(atom/target, mob/user, atom/cleaner, cleanspeed = 50, text1 = "clean", text2 = " with [src].", text3 = "clean")
	var/cmag_cleantime = 50 //The cleaning time for cmagged objects is locked to this, for balance reasons

	if(user.client && (target in user.client.screen)) //You can't clean items you're wearing for technical reasons
		to_chat(user, "<span class='notice'>You need to take that [target.name] off before cleaning it.</span>")
		return

	if(HAS_TRAIT(target, TRAIT_CMAGGED))
		text1 = "clean the ooze off"
		text3 = "clean the ooze off"
		cleanspeed = cmag_cleantime

	if(istype(target, /obj/effect/decal/cleanable) || istype(target, /obj/effect/rune))
		text1 = "scrub out"
		text3 = "scrub out"

	user.visible_message("<span class='warning'>[user] begins to [text1] \the [target.name][text2]</span>")
	if(!do_after(user, cleanspeed, target = target) && target)
		return

	user.visible_message("<span class='notice'>You [text3] \the [target.name][text2]</span>")

	if(text3 == "clean the ooze off") //If we've cleaned a cmagged object
		REMOVE_TRAIT(target, TRAIT_CMAGGED, "clown_emag")
		cleaner.post_clean(target, user, cleaner)
		return

	if(text3 == "scrub out") //If we're a decal (that can't get no love from me)
		if(issimulatedturf(target.loc))
			clean_turf(target.loc, user, cleaner)
			return
		qdel(target)

	if(issimulatedturf(target)) //If we're cleaning turf
		clean_turf(target, user, cleaner)
	else
		//What are we cleaning? IDK, but clean it anyways
		var/obj/effect/decal/cleanable/C = locate() in target
		qdel(C)
		target.clean_blood()

/atom/proc/clean_turf(turf/simulated/T, mob/user, atom/cleaner)
	if(cleaner.can_clean())
		T.clean_blood()
		for(var/obj/effect/O in T)
			if(O.is_cleanable())
				qdel(O)
	cleaner.post_clean(T, user, cleaner)

/atom/proc/can_clean() //For determining if a cleaning object can actually remove decals
	return FALSE

/atom/proc/post_clean(atom/target, mob/user, atom/cleaner) //For object-specifc behaviors after cleaning, such as mops making floors slippery
	return
