/datum/event/spawn_pulsedemon
	var/key_of_pulsedemon

/datum/event/spawn_pulsedemon/proc/get_pulsedemon()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a pulse demon?", ROLE_PULSEDEMON, FALSE, source = /mob/living/simple_animal/pulse_demon)
	if(!length(candidates))
		kill()
		return

	var/mob/C = pick(candidates)
	key_of_pulsedemon = C.key

	if(!key_of_pulsedemon)
		kill()
		return

	var/datum/mind/player_mind = new /datum/mind(key_of_pulsedemon)
	player_mind.active = TRUE

	var/turf/spawn_loc = get_spawn_loc(player_mind.current)
	var/mob/living/simple_animal/pulse_demon/demon = new(spawn_loc)
	player_mind.transfer_to(demon)
	player_mind.assigned_role = SPECIAL_ROLE_PULSEDEMON
	player_mind.special_role = SPECIAL_ROLE_PULSEDEMON
	demon.give_objectives()
	message_admins("[key_name_admin(demon)] has been made into a [initial(demon.name)] by an event.")
	log_game("[key_name_admin(demon)] was spawned as a [initial(demon.name)] by an event.")

/datum/event/spawn_pulsedemon/proc/get_spawn_loc()
	RETURN_TYPE(/turf)
	var/list/spawn_centers = list()
	for(var/datum/regional_powernet/P in SSmachines.powernets)
		for(var/obj/structure/cable/C in P.cables)
			var/turf/simulated/floor/F = get_turf(C)
			// is a floor, not tiled, on station, in maintenance and cable has power?
			if(istype(F) && !F.intact && is_station_level(C.z) && istype(get_area(C), /area/maintenance) && P.available_power > 0)
				spawn_centers += F
	if(!spawn_centers)
		kill()
		return
	return pick(spawn_centers)

/datum/event/spawn_pulsedemon/start()
	INVOKE_ASYNC(src, PROC_REF(get_pulsedemon))
