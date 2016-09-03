
var/global/obj/machinery/mob_hunt_server/mob_hunt_server = null

/obj/machinery/mob_hunt_server
	name = "Nano-Mob Hunter GO Server "
	desc = "A game server for the new hit PDA game \"Nano-Mob Hunter GO\". May be unstable."
	icon_state = "processor"
	density = 1
	anchored = 1
	var/max_normal_spawns = 15		//change this to adjust the number of normal spawns that can exist at one time. trapped spawns (from traitors) don't count towards this
	var/list/normal_spawns = list()
	var/list/trap_spawns = list()
	var/list/connected_clients = list()
	var/server_instability = 0		//tracks the instability of the game server. trapped mobs and users increase instability, which causes random kicks and eventually crashing
	var/server_status = 1			//1 is online, 0 is offline

/obj/machinery/mob_hunt_server/New()
	..()
	if(!mob_hunt_server)
		mob_hunt_server = src
	else
		log_admin("A Nano-Mob Hunter GO server was created at ([x], [y]) on z[z] while one already exists. Deleting the new server.")
		//there can only be one!
		qdel(src)

/obj/machinery/mob_hunt_server/Destroy()
	for(var/datum/data/pda/app/mob_hunter_game/client in connected_clients)
		client.disconnect("Server Destruction")
	if(mob_hunt_server && mob_hunt_server == src)
		mob_hunt_server = null
	return ..()

/obj/machinery/mob_hunt_server/process()
	..()
	if(server_status == 0)
		return
	if(normal_spawns.len < max_normal_spawns)
		spawn_mob()
	check_stability()
	if(server_instability >= 75)
		if(server_instability >= 100)
			server_crash()
		else if(prob(server_instability - 50))
			server_crash()

	if(server_instability >= 25 && connected_clients.len >= 5)
		if(prob(server_instability))
			var/datum/data/pda/app/mob_hunter_game/client = pick(connected_clients)
			client.disconnect("Server Communication Error")

/obj/machinery/mob_hunt_server/proc/check_stability()
	server_instability = connected_clients.len + (trap_spawns.len * 5)

/obj/machinery/mob_hunt_server/proc/server_crash()
	server_status = 0
	for(var/datum/data/pda/app/mob_hunter_game/client in connected_clients)
		client.disconnect("Server Crash")
	for(var/obj/effect/nanomob/N in trap_spawns)
		N.despawn()
	for(var/obj/effect/nanomob/N in normal_spawns)
		N.despawn()
	//just in case
	normal_spawns.Cut()
	trap_spawns.Cut()
	connected_clients.Cut()
	//set a timer to automatically recover in 5 minutes (can be manually restarted if you get impatient too)
	addtimer(src, "auto_recover", 3000, TRUE)

/obj/machinery/mob_hunt_server/proc/auto_recover()
	if(server_status != 0)
		return
	server_instability = 0
	server_status = 1
	while(normal_spawns.len < max_normal_spawns)		//repopulate the server's spawns completely if we auto-recover from crash
		spawn_mob()

/obj/machinery/mob_hunt_server/proc/manual_reboot()
	for(var/obj/effect/nanomob/N in trap_spawns)
		N.despawn()
	for(var/obj/effect/nanomob/N in normal_spawns)
		N.despawn()
	check_stability()
	server_status = 1

/obj/machinery/mob_hunt_server/proc/spawn_mob()
	var/list/nanomob_types = subtypesof(/datum/mob_hunt)
	var/datum/mob_hunt/mob_info = pick(nanomob_types)
	new mob_info()

/obj/machinery/mob_hunt_server/proc/register_spawn(datum/mob_hunt/mob_info)
	if(!mob_info)
		return 0
	var/obj/effect/nanomob/new_mob = new /obj/effect/nanomob(locate(mob_info.x_coord, mob_info.y_coord, STATION_LEVEL), mob_info)
	normal_spawns += new_mob
	return 1

/obj/machinery/mob_hunt_server/proc/register_trap(datum/mob_hunt/mob_info)
	if(!mob_info)
		return 0
	if(!mob_info.is_trap)
		return register_spawn()
	var/obj/effect/nanomob/new_mob = new /obj/effect/nanomob(locate(mob_info.x_coord, mob_info.y_coord, STATION_LEVEL), mob_info)
	trap_spawns += new_mob
	check_stability()
	return 1