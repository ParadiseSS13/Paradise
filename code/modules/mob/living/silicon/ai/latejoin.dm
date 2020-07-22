var/global/list/empty_playable_ai_cores = list()

/hook/roundstart/proc/spawn_empty_ai()
	for(var/obj/effect/landmark/start/S in GLOB.landmarks_list)
		if(S.name != "AI")
			continue
		if(locate(/mob/living) in S.loc)
			continue
		empty_playable_ai_cores += new /obj/structure/AIcore/deactivated(get_turf(S))

	return 1

/mob/living/silicon/ai/verb/wipe_core()
	set name = "Wipe Core"
	set category = "OOC"
	set desc = "Wipe your core. This is functionally equivalent to cryo or robotic storage, freeing up your job slot."

	// Guard against misclicks, this isn't the sort of thing we want happening accidentally
	if(alert("WARNING: This will immediately wipe your core and ghost you, removing your character from the round permanently (similar to cryo and robotic storage). Are you entirely sure you want to do this?",
					"Wipe Core", "No", "No", "Yes") != "Yes")
		return

	// We warned you.
	empty_playable_ai_cores += new /obj/structure/AIcore/deactivated(loc)
	global_announcer.autosay("[src] has been moved to intelligence storage.", "Artificial Intelligence Oversight")

	//Handle job slot/tater cleanup.
	var/job = mind.assigned_role

	SSjobs.FreeRole(job)

	if(mind.objectives.len)
		mind.objectives.Cut()
		mind.special_role = null
	else
		if(SSticker.mode.name == "AutoTraitor")
			var/datum/game_mode/traitor/autotraitor/current_mode = SSticker.mode
			current_mode.possible_traitors.Remove(src)

	// Ghost the current player and disallow them to return to the body
	ghostize(FALSE)
	// Delete the old AI shell
	qdel(src)

// TODO: Move away from the insane name-based landmark system
/mob/living/silicon/ai/proc/moveToAILandmark()
	var/obj/loc_landmark
	for(var/obj/effect/landmark/start/sloc in GLOB.landmarks_list)
		if(sloc.name != "AI")
			continue
		if(locate(/mob/living) in sloc.loc)
			continue
		loc_landmark = sloc
	if(!loc_landmark)
		for(var/obj/effect/landmark/tripai in GLOB.landmarks_list)
			if(tripai.name == "tripai")
				if(locate(/mob/living) in tripai.loc)
					continue
				loc_landmark = tripai
	if(!loc_landmark)
		to_chat(src, "Oh god sorry we can't find an unoccupied AI spawn location, so we're spawning you on top of someone.")
		for(var/obj/effect/landmark/start/sloc in GLOB.landmarks_list)
			if(sloc.name == "AI")
				loc_landmark = sloc

	forceMove(loc_landmark.loc)
	view_core()

// Before calling this, make sure an empty core exists, or this will no-op
/mob/living/silicon/ai/proc/moveToEmptyCore()
	if(!empty_playable_ai_cores.len)
		log_runtime(EXCEPTION("moveToEmptyCore called without any available cores"), src)
		return

	// IsJobAvailable for AI checks that there is an empty core available in this list
	var/obj/structure/AIcore/deactivated/C = empty_playable_ai_cores[1]
	empty_playable_ai_cores -= C

	forceMove(C.loc)
	view_core()

	qdel(C)
