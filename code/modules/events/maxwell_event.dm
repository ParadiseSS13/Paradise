/datum/event/spawn_maxwell
	name = "Maxwell"

/datum/event/spawn_maxwell/proc/get_spawn_loc()
	var/list/possible_spawns = GLOB.nukedisc_respawn
	while(length(possible_spawns))
		var/turf/current_spawn = pick_n_take(possible_spawns)
		if(!current_spawn.density)
			return current_spawn
		// Someone built a wall over it, check the surroundings
		var/list/open_turfs = current_spawn.AdjacentTurfs(open_only = TRUE)
		if(length(open_turfs))
			return pick(open_turfs)

/datum/event/spawn_maxwell/start()
	var/turf/spawn_loc = get_spawn_loc()
	var/obj/item/toy/plushie/maxwell/maxwell = new /obj/item/toy/plushie/maxwell(spawn_loc, TRUE, TRUE)
	GLOB.poi_list.Add(maxwell)
	GLOB.major_announcement.Announce("A legendary MAXWELL has appeared on [station_name()]! All personnel must attempt to retrieve the cat!", "MAXWELL!!!", 'sound/items/maxwell.ogg')
	announce_to_ghosts(maxwell)
