/datum/event/spawn_floor_cluwne


/datum/event/spawn_floor_cluwne/start()

	if(!GLOB.xeno_spawn)
		message_admins("No valid spawn locations found, aborting...")
		return kill()

	var/turf/T = get_turf(pick(GLOB.xeno_spawn))
	var/mob/living/simple_animal/hostile/floor_cluwne/S = new(T)
	playsound(S, 'sound/spookoween/scary_horn.ogg', 50, 1, -1)
	message_admins("A floor cluwne([ADMIN_VV(S, "VV")]) has been spawned at [ADMIN_COORDJMP(T)]")
	add_game_logs("A floor cluwne has been spawned at [COORD(T)]")
	return 1
