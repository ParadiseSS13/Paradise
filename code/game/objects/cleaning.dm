#define CMAG_CLEANTIME 50 //The cleaning time for cmagged objects is locked to this, for balance reasons


//For handling standard click-to-clean items like soap and mops.

//text_verb and text_description carry strings that, when pieced together by this proc, make the cleaning messages.
//text_verb is the verb that'll be used for cleaning, i.e. "User begins to [mop] the floor."

//text_description by default appends the name of the cleaning object to the cleaning message, i.e. "User begins to clean the floor[ with soap.]"
//If text_description is ".", the sentence will end early (so you don't say "Lusty Xenomorph Maid begins to clean the floor with the Lusty Xenomorph Maid")

//text_targetname is the name of the object being interacted with, i.e. "User begins to scrub out the [rune] with the damp rag."
//Can normally be left alone, but needs to be defined if the thing being cleaned isn't necessarily the thing being clicked on,
//such as /obj/effect/rune/cleaning_act() bouncing to turf/simulated/cleaning_act().

/atom/proc/cleaning_act(mob/user, atom/cleaner, cleanspeed = 5 SECONDS, text_verb = "clean", text_description = " with [cleaner].", text_targetname = name)
	var/is_cmagged = FALSE

	if(user.client && (src in user.client.screen)) //You can't clean items you're wearing for technical reasons
		to_chat(user, "<span class='notice'>You need to take that [text_targetname] off before cleaning it.</span>")
		return FALSE

	// Consolidate cmagged trait checks and update cleaning parameters
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		is_cmagged = TRUE
		text_verb = "clean the ooze off"
		cleanspeed = CMAG_CLEANTIME

	// Display cleaning message to the user and others
	user.visible_message("<span class='warning'>[user] begins to [text_verb] [text_targetname][text_description]</span>", "<span class='warning'>You begin to [text_verb] [text_targetname][text_description]</span>")

	// Execute cleaning action with the defined cleaning speed
	if(!do_after(user, cleanspeed, target = src))
		return FALSE

	// Check if the cleaner can clean and execute post-clean actions
	if(!cleaner.can_clean())
		cleaner.post_clean(src, user)
		return FALSE

	// Perform post-clean actions
	cleaner.post_clean(src, user)

	// Notify user of successful cleaning
	to_chat(user, "<span class='notice'>You [text_verb] [text_targetname][text_description]</span>")

	// Handle cmagged objects after cleaning
	if(is_cmagged)
		REMOVE_TRAIT(src, TRAIT_CMAGGED, CLOWN_EMAG)
		uncmag()
		return TRUE
	else
		// Generic cleaning functionality
		var/obj/effect/decal/cleanable/decal_to_clean = locate() in src
		if(decal_to_clean)
			qdel(decal_to_clean)
		clean_blood()
		SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT)
		return TRUE

/atom/proc/can_clean() //For determining if a cleaning object can actually remove decals
	return FALSE

/atom/proc/post_clean(atom/target, mob/user) //For specific cleaning object behaviors after cleaning, such as mops making floors slippery.
	// Example: Make floors slippery after mopping
	if(istype(target, /turf))
		to_chat(user, "<span class='notice'>The floor is now slippery!</span>")
	return

/*
	* # machine_wash()
	*
	* Called by machinery/washing_machine during its wash cycle
	* Allows custom behavior to be implemented on items that are put through the washing machine.
	* By default, it un-cmags objects and cleans all contaminants off the item.
	*
	* Parameters:
	* - source: the washing_machine that is responsible for the washing, used by overrides to detect color to dye with.
*/
/atom/movable/proc/machine_wash(obj/machinery/washing_machine/source)
	// Remove cmag trait if present
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		uncmag()
		REMOVE_TRAIT(src, TRAIT_CMAGGED, CLOWN_EMAG)

	// Generic cleaning functionality
	var/obj/effect/decal/cleanable/decal_to_clean = locate() in src
	if(!QDELETED(decal_to_clean))
		qdel(decal_to_clean)
	clean_blood()

#undef CMAG_CLEANTIME
