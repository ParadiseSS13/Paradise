/datum/event/flockmind
	name = "Flockmind"
	noAutoEnd = TRUE
	nominal_severity = EVENT_LEVEL_DISASTER
	role_weights = list(ASSIGNMENT_SECURITY = 2, ASSIGNMENT_CREW = 0.7, ASSIGNMENT_MEDICAL = 2)
	role_requirements = list(ASSIGNMENT_SECURITY = 3, ASSIGNMENT_CREW = 40, ASSIGNMENT_MEDICAL = 3)
	/// So we don't make a command report if nothing gets spawned.
	var/successSpawn = FALSE

/datum/event/flockmind/proc/make_blob()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a Flockmind?", ROLE_FLOCK, TRUE, source = /mob/camera/flock/overmind)
	if(!length(candidates))
		return kill()

	var/mob/C
	while(length(candidates))
		C = pick_n_take(candidates)
		if(jobban_isbanned(C, ROLE_TRAITOR))
			continue
		break
	if(!C)
		kill()
		return
	var/player_key = C.key

	if(!player_key)
		kill()
		return

	var/datum/mind/player_mind = new /datum/mind(player_key)
	player_mind.active = TRUE
	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/spawner/flock/spawn_site in GLOB.landmarks_list)
		spawn_locs += get_turf(spawn_site)
	if(!spawn_locs) // If we can't find any, then give up
		kill()
		return
	var/mob/camera/flock/overmind/flockmind = new /mob/camera/flock/overmind(pick(spawn_locs))
	player_mind.transfer_to(flockmind)
	dust_if_respawnable(C)
	player_mind.assigned_role = SPECIAL_ROLE_FLOCK
	player_mind.special_role = SPECIAL_ROLE_FLOCK
	player_mind.add_antag_datum(/datum/antagonist/flock)
	SSticker.mode.traitors |= player_mind
	log_admin("[player_key] has been made into a flockmind by an event.")
	log_game("[player_key] was spawned as a flockmind by an event.")
