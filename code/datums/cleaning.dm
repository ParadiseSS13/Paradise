//For handling standard click-to-clean items like soap and mops.
/atom/proc/cleaning_act(atom/target, mob/user, atom/cleaner, cleanspeed = 50, ismop = FALSE)
	var/innatecleaner = FALSE //If the user cleaning is innately able to clean, i.e. Lusty Xenomorph Maid
	var/cmag_cleantime = 50 //The cleaning time for cmagged objects is locked to this, for balance reasons

	if(user == cleaner)
		innatecleaner = TRUE

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
		if(!innatecleaner)
			user.visible_message("<span class='warning'>[user] begins to scrub \the [target.name] out with [src].</span>")
		else
			user.visible_message("<span class='warning'>[user] begins to scrub out \the [target.name].</span>")
		if(do_after(user, cleanspeed, target = target) && target)
			to_chat(user, "<span class='notice'>You scrub \the [target.name] out.</span>")
			if(issimulatedturf(target.loc))
				clean_turf(target.loc, cleaner, ismop)
				return
			qdel(target)
		return

	if(issimulatedturf(target))
		if(!innatecleaner)
			user.visible_message("<span class='warning'>[user] begins to clean \the [target.name] with [src].</span>")
		else
			user.visible_message("<span class='warning'>[user] begins to clean \the [target.name].</span>")
		if(do_after(user, cleanspeed, target = target))
			to_chat(user, "<span class='notice'>You clean \the [target.name].</span>")
			clean_turf(target, cleaner, ismop)
	else
		if(!innatecleaner)
			user.visible_message("<span class='warning'>[user] begins to clean \the [target.name] with [src].</span>")
		else
			user.visible_message("<span class='warning'>[user] begins to clean \the [target.name].</span>")
		if(do_after(user, cleanspeed, target = target))
			to_chat(user, "<span class='notice'>You clean \the [target.name].</span>")
			var/obj/effect/decal/cleanable/C = locate() in target
			qdel(C)
			target.clean_blood()

/atom/proc/clean_turf(turf/simulated/T, atom/cleaner, ismop = FALSE)
	var/canclean = TRUE

	if(ismop)
		if(cleaner.reagents.has_reagent("water", 0) && cleaner.reagents.has_reagent("cleaner", 0) && cleaner.reagents.has_reagent("holywater", 0))
			canclean = FALSE
		cleaner.reagents.reaction(T, REAGENT_TOUCH, 10)	//10 is the multiplier for the reaction effect. probably needed to wet the floor properly.
		cleaner.reagents.remove_any(1)			//reaction() doesn't use up the reagents

	if(canclean)
		T.clean_blood()
		for(var/obj/effect/O in T)
			if(O.is_cleanable())
				qdel(O)

/atom/proc/iscleaner(obj/C) //All objects that use the above procs (Lusty Xenomorph Maid is not an object, sorry!)
	var/list/cleaning_items = list(
		/obj/item/soap,
		/obj/item/mop,
		/obj/item/reagent_containers/glass/rag
	)
	for(var/thing in cleaning_items)
		if(istype(C, thing))
			return TRUE
	return FALSE
