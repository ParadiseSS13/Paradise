#define CMAG_CLEANTIME 50 //The cleaning time for cmagged objects is locked to this, for balance reasons


//For handling standard click-to-clean items like soap and mops.

//text_verb and text_description carry strings that, when pieced together by this proc, make the cleaning messages.
//text_verb is the verb that'll be used for cleaning, i.e. "User begins to [mop] the floor."

//text_description by default appends the name of the cleaning object to the cleaning message, i.e. "User begins to clean the floor[ with soap.]"
//If text_description is ".", the sentence will end early (so you don't say "Lusty Xenomorph Maid begins to clean the floor with the Lusty Xenomorph Maid")

//text_targetname is the name of the object being interacted with, i.e. "User begins to scrub out the [rune] with the damp rag."
//Can normally be left alone, but needs to be defined if the thing being cleaned isn't necessarily the thing being clicked on,
//such as /obj/effect/rune/cleaning_act() bouncing to turf/simulated/cleaning_act().

// skip_do_after - When TRUE, do after and visible messages are disabled

/atom/proc/cleaning_act(mob/user, atom/cleaner, cleanspeed = 5 SECONDS, text_verb = "clean", text_description = " with [cleaner].", text_targetname = name, skip_do_after = FALSE)
	var/is_cmagged = FALSE

	if(user.client && (src in user.client.screen)) //You can't clean items you're wearing for technical reasons
		to_chat(user, "<span class='notice'>You need to take that [text_targetname] off before cleaning it.</span>")
		return FALSE

	var/is_dirty = FALSE
	if(HAS_TRAIT(src, TRAIT_CMAGGED)) //So we don't need a cleaning_act for every cmaggable object
		is_cmagged = TRUE
		text_verb = "clean the ooze off"
		cleanspeed = CMAG_CLEANTIME
		is_dirty = TRUE
	else if(ismob(src))
		// Mobs always get cleaned directly, because humans have clothing that needs cleaning, and because it'd just feel weird to automatically clean under them.
		is_dirty = TRUE
	else if(blood_DNA)
		is_dirty = TRUE
	else
		for(var/obj/effect/decal/cleanable/C in src)
			is_dirty = TRUE
			break

	if(!is_dirty && !isturf(src))
		// We don't need cleaning, so let's spare the janitor a pixel hunt and let the floor under us get cleaned instead.
		var/turf/T = get_turf(src)
		return T.cleaning_act(user, cleaner, cleanspeed, text_verb, " under [src][text_description].", skip_do_after=skip_do_after)

	if(!skip_do_after)
		user.visible_message("<span class='warning'>[user] begins to [text_verb] \the [text_targetname][text_description]</span>", "<span class='warning'>You begin to [text_verb] \the [text_targetname][text_description]</span>")
		if(!do_after(user, cleanspeed, target = src))
			return FALSE

	if(!cleaner.can_clean())
		cleaner.post_clean(src, user)
		return FALSE

	cleaner.post_clean(src, user)

	if(!skip_do_after)
		to_chat(user, "<span class='notice'>You [text_verb] \the [text_targetname][text_description]</span>")

	if(is_cmagged) //If we've cleaned a cmagged object
		REMOVE_TRAIT(src, TRAIT_CMAGGED, CLOWN_EMAG)
		uncmag()
		return TRUE
	else
		//Generic cleaning functionality
		for(var/obj/effect/decal/cleanable/C in src)
			qdel(C)
		clean_blood()
		SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT)
		return TRUE

/atom/proc/can_clean() //For determining if a cleaning object can actually remove decals
	return FALSE

/atom/proc/post_clean(atom/target, mob/user) //For specific cleaning object behaviors after cleaning, such as mops making floors slippery.
	return

/*
	* # machine_wash()
	*
	* Called by machinery/washing_machine during its wash cycle
	* allows custom behaviour to be implemented on items that are put through the washing machine
	* by default it un cmag's objects and cleans all contaminents off of the item
	*
	* source - the washing_machine that is responsible for the washing, used by overrides to detect color to dye with
*/
/atom/movable/proc/machine_wash(obj/machinery/washing_machine/source)
	if(HAS_TRAIT(src, TRAIT_CMAGGED)) //If we've cleaned a cmagged object
		uncmag()
		REMOVE_TRAIT(src, TRAIT_CMAGGED, CLOWN_EMAG)

	//Generic cleaning functionality
	var/obj/effect/decal/cleanable/C = locate() in src
	if(!QDELETED(C))
		qdel(C)
	clean_blood()


#undef CMAG_CLEANTIME
