//==========DAT FUKKEN DISK===============
/obj/item/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "nucleardisk"
	max_integrity = 250
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 30, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	/// Is the disk restricted to the station? If true, also respawns the disk when deleted
	var/restricted_to_station = TRUE

/obj/item/disk/nuclear/unrestricted
	name = "unrestricted nuclear authentication disk"
	desc = "Seems to have been stripped of its safeties, you better not lose it."
	restricted_to_station = FALSE

/obj/item/disk/nuclear/New()
	..()
	if(restricted_to_station)
		START_PROCESSING(SSobj, src)
	GLOB.poi_list |= src

/obj/item/disk/nuclear/process()
	if(!restricted_to_station)
		stack_trace("An unrestricted NAD ([src]) was processing.")
		return PROCESS_KILL
	if(!check_disk_loc())
		var/holder = get(src, /mob)
		if(holder)
			to_chat(holder, "<span class='danger'>You can't help but feel that you just lost something back there...</span>")
		qdel(src)

 //station disk is allowed on the station level, escape shuttle/pods, CC, and syndicate shuttles/base, reset otherwise
/obj/item/disk/nuclear/proc/check_disk_loc()
	if(!restricted_to_station)
		return TRUE
	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	if(is_station_level(T.z))
		return TRUE
	if(A.nad_allowed)
		return TRUE
	return FALSE

/obj/item/disk/nuclear/Destroy(force)
	var/turf/diskturf = get_turf(src)

	if(force)
		message_admins("[src] has been !!force deleted!! in ([diskturf ? "[diskturf.x], [diskturf.y] ,[diskturf.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[diskturf.x];Y=[diskturf.y];Z=[diskturf.z]'>JMP</a>":"nonexistent location"]).")
		log_game("[src] has been !!force deleted!! in ([diskturf ? "[diskturf.x], [diskturf.y] ,[diskturf.z]":"nonexistent location"]).")
		GLOB.poi_list.Remove(src)
		STOP_PROCESSING(SSobj, src)
		return ..()

	if(!restricted_to_station) // Non-restricted NADs should be allowed to be deleted, otherwise it becomes a restricted NAD when teleported
		message_admins("[src] (unrestricted) has been deleted in ([diskturf ? "[diskturf.x], [diskturf.y] ,[diskturf.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[diskturf.x];Y=[diskturf.y];Z=[diskturf.z]'>JMP</a>":"nonexistent location"]). It will not respawn.")
		log_game("[src] (unrestricted) has been deleted in ([diskturf ? "[diskturf.x], [diskturf.y] ,[diskturf.z]":"nonexistent location"]). It will not respawn.")
		GLOB.poi_list.Remove(src)
		STOP_PROCESSING(SSobj, src)
		return ..()

	var/turf/new_spawn = find_respawn()
	if(new_spawn)
		GLOB.poi_list.Remove(src)
		var/obj/item/disk/nuclear/NEWDISK = new(new_spawn)
		transfer_fingerprints_to(NEWDISK)
		message_admins("[src] has been destroyed at ([diskturf.x], [diskturf.y], [diskturf.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[diskturf.x];Y=[diskturf.y];Z=[diskturf.z]'>JMP</a>). Moving it to ([NEWDISK.x], [NEWDISK.y], [NEWDISK.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[NEWDISK.x];Y=[NEWDISK.y];Z=[NEWDISK.z]'>JMP</a>).")
		log_game("[src] has been destroyed in ([diskturf.x], [diskturf.y], [diskturf.z]). Moving it to ([NEWDISK.x], [NEWDISK.y], [NEWDISK.z]).")
		return QDEL_HINT_HARDDEL_NOW
	else
		error("[src] was supposed to be destroyed, but we were unable to locate a nukedisc_respawn landmark or open surroundings to spawn a new one.")
	return QDEL_HINT_LETMELIVE // Cancel destruction unless forced.

/obj/item/disk/nuclear/proc/find_respawn()
	var/list/possible_spawns = GLOB.nukedisc_respawn
	while(length(possible_spawns))
		var/turf/current_spawn = pick_n_take(possible_spawns)
		if(!current_spawn.density)
			return current_spawn
		// Someone built a wall over it, check the surroundings
		var/list/open_turfs = current_spawn.AdjacentTurfs(open_only = TRUE)
		if(length(open_turfs))
			return pick(open_turfs)
