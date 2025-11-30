#define REVENANT_SPAWN_THRESHOLD 10

/datum/event/revenant
	name = "Revenant"
	nominal_severity = EVENT_LEVEL_MAJOR
	noAutoEnd = TRUE
	role_weights = list(ASSIGNMENT_CHAPLAIN = 5, ASSIGNMENT_CREW = 0.8)
	role_requirements = list(ASSIGNMENT_CHAPLAIN = 1, ASSIGNMENT_CREW = 30)
	var/key_of_revenant

// Calculated separately from event
/datum/event/revenant/event_resource_cost()
	return list()

/datum/event/revenant/proc/on_revenant_death(mob/source)
	SIGNAL_HANDLER // COMSIG_MOB_DEATH
	UnregisterSignal(source, COMSIG_MOB_DEATH)
	kill()

/datum/event/revenant/proc/get_revenant(end_if_fail = 0)
	var/deadMobs = 0
	for(var/mob/M in GLOB.dead_mob_list)
		deadMobs++
	if(deadMobs < REVENANT_SPAWN_THRESHOLD)
		message_admins("Random event attempted to spawn a revenant, but there were only [deadMobs]/[REVENANT_SPAWN_THRESHOLD] dead mobs.")
		kill()
		return

	spawn()
		var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a revenant?", ROLE_REVENANT, TRUE, source = /mob/living/basic/revenant)
		if(!length(candidates))
			key_of_revenant = null
			kill()
			return
		var/mob/C = pick(candidates)
		key_of_revenant = C.key

		if(!key_of_revenant)
			kill()
			return

		var/datum/mind/player_mind = new /datum/mind(key_of_revenant)
		player_mind.active = TRUE
		var/list/spawn_locs = list()
		for(var/obj/effect/landmark/spawner/rev/R in GLOB.landmarks_list)
			spawn_locs += get_turf(R)
		if(!spawn_locs) //If we can't find a good place, just spawn the revenant at the player's location
			spawn_locs += get_turf(player_mind.current)
		if(!spawn_locs) //If we can't find THAT, then give up
			kill()
			return
		var/mob/living/basic/revenant/revvie = new /mob/living/basic/revenant/(pick(spawn_locs))
		RegisterSignal(revvie, COMSIG_MOB_DEATH, PROC_REF(on_revenant_death))
		player_mind.transfer_to(revvie)
		dust_if_respawnable(C)
		player_mind.assigned_role = SPECIAL_ROLE_REVENANT
		player_mind.special_role = SPECIAL_ROLE_REVENANT
		SSticker.mode.traitors |= player_mind
		message_admins("[key_of_revenant] has been made into a revenant by an event.")
		log_game("[key_of_revenant] was spawned as a revenant by an event.")

/datum/event/revenant/start()
	get_revenant()

#undef REVENANT_SPAWN_THRESHOLD
