//For handling standard click-to-clean items like soap and mops.
//text1, text2, and text3 carry strings that, when pieced together by this proc, make the cleaning messages.
/atom/proc/cleaning_act(atom/target, mob/user, atom/cleaner, cleanspeed = 50, text1 = "begins to clean", text2 = " with [src].", text3 = "clean")
	var/cmag_cleantime = 50 //The cleaning time for cmagged objects is locked to this, for balance reasons

	if(HAS_TRAIT(target, TRAIT_CMAGGED))
		user.visible_message("<span class='notice'>[user] starts to clean the ooze off \the [target.name].</span>", "<span class='notice'>You start to clean the ooze off \the [target.name].</span>")
		if(do_after(user, cmag_cleantime, target = target) && target)
			user.visible_message("<span class='notice'>[user] cleans the ooze off \the [target.name].</span>", "<span class='notice'>You clean the ooze off \the [target.name].</span>")
			REMOVE_TRAIT(target, TRAIT_CMAGGED, "clown_emag")
		return

	if(user.client && (target in user.client.screen)) //You can't clean items you're wearing for technical reasons
		to_chat(user, "<span class='notice'>You need to take that [target.name] off before cleaning it.</span>")
		return

	if(istype(target, /obj/effect/decal/cleanable) || istype(target, /obj/effect/rune))
		user.visible_message("<span class='warning'>[user] begins to scrub out \the [target.name][text2]</span>")
		if(do_after(user, cleanspeed, target = target) && target)
			to_chat(user, "<span class='notice'>You scrub \the [target.name] out.</span>")
			if(issimulatedturf(target.loc))
				clean_turf(target.loc, user, cleaner)
				return
			qdel(target)
		return

	if(issimulatedturf(target))
		user.visible_message("<span class='warning'>[user] [text1] \the [target.name][text2]</span>")
		if(do_after(user, cleanspeed, target = target))
			to_chat(user, "<span class='notice'>You [text3] \the [target.name].</span>")
			clean_turf(target, user, cleaner)
	else
		user.visible_message("<span class='warning'>[user] [text1] \the [target.name][text2]</span>")
		if(do_after(user, cleanspeed, target = target))
			to_chat(user, "<span class='notice'>You [text3] \the [target.name].</span>")
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
