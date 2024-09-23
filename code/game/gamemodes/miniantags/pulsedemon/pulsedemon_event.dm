/// A pulse demon requires 1000 watts to regenerate
#define DEMON_REQUIRED_POWER 1000

/datum/event/spawn_pulsedemon
	var/key_of_pulsedemon

/datum/event/spawn_pulsedemon/proc/get_pulsedemon()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a pulse demon?", ROLE_DEMON, FALSE, source = /mob/living/simple_animal/demon/pulse_demon)
	if(!length(candidates))
		message_admins("no candidates were found for the pulse demon event.")
		kill()
		return

	var/mob/C = pick(candidates)
	key_of_pulsedemon = C.key
	dust_if_respawnable(C)

	if(!key_of_pulsedemon)
		kill()
		return

	var/datum/mind/player_mind = new /datum/mind(key_of_pulsedemon)
	player_mind.active = TRUE

	var/turf/spawn_loc = get_spawn_loc(player_mind.current)
	var/mob/living/simple_animal/demon/pulse_demon/demon = new(spawn_loc)
	player_mind.transfer_to(demon)
	message_admins("[key_name_admin(demon)] has been made into a [initial(demon.name)] by an event.")
	log_game("[key_name_admin(demon)] was spawned as a [initial(demon.name)] by an event.")

/datum/event/spawn_pulsedemon/proc/get_spawn_loc()
	var/list/spawn_centers = list()
	for(var/datum/regional_powernet/P in SSmachines.powernets)
		for(var/obj/structure/cable/C in P.cables)
			if(!is_station_level(C.z) || P.available_power < DEMON_REQUIRED_POWER)
				break // skip iterating over this entire powernet, it's not on station or it has zero available power (so it's not suitable)

			var/turf/simulated/floor/F = get_turf(C)
			// is a floor, not tiled, on station, in maintenance and cable has power?
			if(istype(F) && (!F.intact && !F.transparent_floor) && istype(get_area(C), /area/station/maintenance))
				spawn_centers += F
	if(!length(spawn_centers))
		message_admins("no suitable spawn locations were found for the pulse demon event.")
		log_debug("no suitable spawn locations were found for the pulse demon event.")
		kill()
		return
	return pick(spawn_centers)

/datum/event/spawn_pulsedemon/start()
	INVOKE_ASYNC(src, PROC_REF(get_pulsedemon))

#undef DEMON_REQUIRED_POWER
