#define REVENANT_SPAWN_THRESHOLD 10

/datum/event/revenant
	var/key_of_revenant


/datum/event/revenant/proc/get_revenant(var/end_if_fail = 0)
	var/deadMobs = 0
	for(var/mob/M in dead_mob_list)
		deadMobs++
	if(deadMobs < REVENANT_SPAWN_THRESHOLD)
		message_admins("Random event attempted to spawn a revenant, but there were only [deadMobs]/[REVENANT_SPAWN_THRESHOLD] dead mobs.")
		return

	spawn()
		var/list/candidates = pollCandidates("Do you want to play as a revenant?", ROLE_REVENANT, 1)
		if(!candidates.len)
			key_of_revenant = null
			return kill()
		var/mob/C = pick(candidates)
		key_of_revenant = C.key

		if(!key_of_revenant)
			return kill()

		var/datum/mind/player_mind = new /datum/mind(key_of_revenant)
		player_mind.active = 1
		var/list/spawn_locs = list()
		for(var/obj/effect/landmark/L in landmarks_list)
			if(isturf(L.loc))
				switch(L.name)
					if("revenantspawn")
						spawn_locs += L.loc
		if(!spawn_locs) //If we can't find any revenant spawns, try the carp spawns
			for(var/obj/effect/landmark/L in landmarks_list)
				if(isturf(L.loc))
					switch(L.name)
						if("carpspawn")
							spawn_locs += L.loc
		if(!spawn_locs) //If we can't find either, just spawn the revenant at the player's location
			spawn_locs += get_turf(player_mind.current)
		if(!spawn_locs) //If we can't find THAT, then just retry
			return kill()
		var/mob/living/simple_animal/revenant/revvie = new /mob/living/simple_animal/revenant/(pick(spawn_locs))
		player_mind.transfer_to(revvie)
		player_mind.assigned_role = "revenant"
		player_mind.special_role = SPECIAL_ROLE_REVENANT
		ticker.mode.traitors |= player_mind
		message_admins("[key_of_revenant] has been made into a revenant by an event.")
		log_game("[key_of_revenant] was spawned as a revenant by an event.")
		return 1


/datum/event/revenant/start()
	get_revenant()