/datum/event/spawn_floor_cluwne


/datum/event/spawn_floor_cluwne/start()

	if(!xeno_spawn)
		message_admins("No valid spawn locations found, aborting...")
		return kill()

	var/turf/T = get_turf(pick(xeno_spawn))
	var/mob/living/simple_animal/hostile/floor_cluwne/S = new(T)
	playsound(S, 'sound/spookoween/scary_horn.ogg', 50, 1, -1)
	message_admins("A floor cluwne has been spawned at [COORD(T)][ADMIN_JMP(T)]")
	log_game("A floor cluwne has been spawned at [COORD(T)]")
	return 1