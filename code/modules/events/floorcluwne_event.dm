/datum/event/spawn_floor_cluwne
	nominal_severity = EVENT_LEVEL_MODERATE
	role_weights = list(ASSIGNMENT_SECURITY = 3, ASSIGNMENT_CREW = 0.8)
	role_requirements = list(ASSIGNMENT_SECURITY = 1, ASSIGNMENT_CREW = 15)

/datum/event/spawn_floor_cluwne/start()

	if(!GLOB.xeno_spawn)
		message_admins("No valid spawn locations found, aborting...")
		return kill()

	var/turf/T = get_turf(pick(GLOB.xeno_spawn))
	var/mob/living/simple_animal/hostile/floor_cluwne/S = new(T)
	playsound(S, 'sound/spookoween/scary_horn.ogg', 50, TRUE, -1)
	message_admins("A floor cluwne has been spawned at [COORD(T)][ADMIN_JMP(T)]")
	log_game("A floor cluwne has been spawned at [COORD(T)]")
	return 1
