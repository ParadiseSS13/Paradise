/datum/event/bizarre_debris
	name = "Bizarre Debris"

/datum/event/bizarre_debris/proc/get_spawn_loc()
	var/list/possible_spawns = GLOB.nukedisc_respawn
	while(length(possible_spawns))
		var/turf/current_spawn = pick_n_take(possible_spawns)
		if(!current_spawn.density)
			return current_spawn
		var/list/open_turfs = current_spawn.AdjacentTurfs(open_only = TRUE)
		if(length(open_turfs))
			return pick(open_turfs)

/datum/event/bizarre_debris/start()
	var/turf/spawn_loc = get_spawn_loc()
	var/obj/item/arrowhead = new /obj/item/arrowhead(spawn_loc, TRUE, TRUE)
	GLOB.poi_list.Add(arrowhead)
	announce_to_ghosts(arrowhead)

	var/turf/spawn_loc2 = get_spawn_loc()
	var/obj/item/arrowhead2 = new /obj/item/arrowhead(spawn_loc2, TRUE, TRUE)
	GLOB.poi_list.Add(arrowhead2)
	announce_to_ghosts(arrowhead2)

	var/turf/spawn_loc3 = get_spawn_loc()
	var/obj/item/arrowhead3 = new /obj/item/arrowhead(spawn_loc3, TRUE, TRUE)
	GLOB.poi_list.Add(arrowhead3)
	announce_to_ghosts(arrowhead3)

	GLOB.major_announcement.Announce("Bizarre anomalous debris has been detected in station maintenance tunnels. Scans indicate unusual biological properties. Crew are advised to locate and secure samples for study.", "Some Sort Of Bizarre Adventure", 'sound/misc/bizarreannounce.ogg')
