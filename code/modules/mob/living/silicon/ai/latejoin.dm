GLOBAL_LIST_EMPTY(empty_playable_ai_cores)

/mob/living/silicon/ai/verb/wipe_core()
	set name = "Wipe Core"
	set category = "OOC"
	set desc = "Wipe your core. This is functionally equivalent to cryo or robotic storage, freeing up your job slot."

	// Guard against misclicks, this isn't the sort of thing we want happening accidentally
	if(alert("WARNING: This will immediately wipe your core and ghost you, removing your character from the round permanently (similar to cryo and robotic storage). Are you entirely sure you want to do this?",
					"Wipe Core", "No", "No", "Yes") != "Yes")
		return
	cryo_AI()

/mob/living/silicon/ai/proc/cryo_AI()
	var/dead_aicore = new /obj/structure/AIcore/deactivated(loc)
	GLOB.empty_playable_ai_cores += dead_aicore
	GLOB.global_announcer.autosay("[src] has been moved to intelligence storage.", "Artificial Intelligence Oversight", follow_target_override = dead_aicore)

	//Handle job slot/tater cleanup.
	var/job = mind.assigned_role

	SSjobs.FreeRole(job)

	if(mind.objective_holder.clear())
		mind.special_role = null
	else
		if(SSticker.mode.name == "AutoTraitor")
			var/datum/game_mode/traitor/autotraitor/current_mode = SSticker.mode
			current_mode.possible_traitors.Remove(src)

	for(var/datum/objective/destroy/O in GLOB.all_objectives)
		if(O.target != mind)
			continue
		O.on_target_cryo()

	view_core()
	// Ghost the current player and disallow them to return to the body
	if(TOO_EARLY_TO_GHOST)
		ghostize(FALSE)
	else
		ghostize(TRUE)
	// Delete the old AI shell
	qdel(src)

/mob/living/silicon/ai/proc/moveToAILandmark()
	var/obj/loc_landmark
	for(var/obj/effect/landmark/start/ai/A in GLOB.landmarks_list)
		if(locate(/mob/living) in get_turf(A))
			continue
		loc_landmark = A
	if(!loc_landmark)
		for(var/obj/effect/landmark/tripai in GLOB.landmarks_list)
			if(tripai.name == "tripai")
				if(locate(/mob/living) in get_turf(tripai))
					continue
				loc_landmark = tripai
	if(!loc_landmark)
		to_chat(src, "Oh god sorry we can't find an unoccupied AI spawn location, so we're spawning you on top of someone.") //lol what is this message
		for(var/obj/effect/landmark/start/ai/A in GLOB.landmarks_list)
			loc_landmark = A

	forceMove(get_turf(loc_landmark))
	view_core()

// Before calling this, make sure an empty core exists, or this will no-op
/mob/living/silicon/ai/proc/moveToEmptyCore()
	if(!GLOB.empty_playable_ai_cores.len)
		CRASH("moveToEmptyCore called without any available cores")

	// IsJobAvailable for AI checks that there is an empty core available in this list
	var/obj/structure/AIcore/deactivated/C = GLOB.empty_playable_ai_cores[1]
	GLOB.empty_playable_ai_cores -= C

	forceMove(C.loc)
	view_core()

	qdel(C)
