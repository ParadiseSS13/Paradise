SUBSYSTEM_DEF(mob_hunt)
	name = "Nano-Mob Hunter GO Server"
	init_order = INIT_ORDER_NANOMOB
	priority = FIRE_PRIORITY_NANOMOB // Low priority, no need for MC_TICK_CHECK due to extremely low performance impact.
	flags = SS_NO_INIT
	offline_implications = "Nano-Mob Hunter will no longer spawn mobs. No immediate action is needed."
	var/max_normal_spawns = 15		//change this to adjust the number of normal spawns that can exist at one time. trapped spawns (from traitors) don't count towards this
	var/list/normal_spawns = list()
	var/max_trap_spawns = 15		//change this to adjust the number of trap spawns that can exist at one time. traps spawned beyond this point clear the oldest traps
	var/list/trap_spawns = list()
	var/list/connected_clients = list()
	var/server_status = 1			//1 is online, 0 is offline
	var/reset_cooldown = 0			//number of controller cycles before the manual_reboot proc can be used again (ignored if server is offline so you can always boot back up)
	var/obj/machinery/computer/mob_battle_terminal/red_terminal
	var/obj/machinery/computer/mob_battle_terminal/blue_terminal
	var/battle_turn = null

/datum/controller/subsystem/mob_hunt/fire(resumed = FALSE)
	if(reset_cooldown)		//if reset_cooldown is set (we are on cooldown, duh), reduce the remaining cooldown every cycle
		reset_cooldown--
	if(!server_status)
		return
	client_mob_update()
	if(normal_spawns.len < max_normal_spawns)
		spawn_mob()

//leaving this here in case admins want to use it for a random mini-event or something
/datum/controller/subsystem/mob_hunt/proc/server_crash(recover_time = 3000)
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
	if(!isnum(recover_time))
		recover_time = 3000
	if(recover_time > 0)	//when provided with a negative or zero valued recover_time argument, the server won't auto-restart but can be manually rebooted still
		//set a timer to automatically recover after recover_time has passed (can be manually restarted if you get impatient too)
		addtimer(CALLBACK(src, .proc/auto_recover), recover_time, TIMER_UNIQUE)

/datum/controller/subsystem/mob_hunt/proc/client_mob_update()
	var/list/ex_players = list()
	for(var/datum/data/pda/app/mob_hunter_game/client in connected_clients)
		var/mob/living/carbon/human/H = client.get_player()
		if(connected_clients[client])
			if(!H || H != connected_clients[client])
				ex_players |= connected_clients[client]
		connected_clients[client] = H
	if(ex_players.len)	//to make sure we don't do this if we didn't lose any player since the last update
		for(var/obj/effect/nanomob/N in (normal_spawns + trap_spawns))
			N.conceal(ex_players)

/datum/controller/subsystem/mob_hunt/proc/auto_recover()
	if(server_status != 0)
		return
	server_status = 1
	while(normal_spawns.len < max_normal_spawns)		//repopulate the server's spawns completely if we auto-recover from crash
		spawn_mob()

/datum/controller/subsystem/mob_hunt/proc/manual_reboot()
	if(server_status && reset_cooldown)
		return 0
	for(var/obj/effect/nanomob/N in trap_spawns)
		N.despawn()
	for(var/obj/effect/nanomob/N in normal_spawns)
		N.despawn()
	server_status = 1
	reset_cooldown = 25		//25 controller cycle cooldown for manual restarts
	return 1

/datum/controller/subsystem/mob_hunt/proc/spawn_mob()
	var/list/nanomob_types = subtypesof(/datum/mob_hunt)
	var/datum/mob_hunt/mob_info = pick(nanomob_types)
	new mob_info()

/datum/controller/subsystem/mob_hunt/proc/register_spawn(datum/mob_hunt/mob_info)
	if(!mob_info)
		return 0
	var/obj/effect/nanomob/new_mob = new /obj/effect/nanomob(mob_info.spawn_point, mob_info)
	normal_spawns += new_mob
	new_mob.reveal()
	return 1

/datum/controller/subsystem/mob_hunt/proc/register_trap(datum/mob_hunt/mob_info)
	if(!mob_info)
		return 0
	if(!mob_info.is_trap)
		return register_spawn(mob_info)
	var/obj/effect/nanomob/new_mob = new /obj/effect/nanomob(mob_info.spawn_point, mob_info)
	trap_spawns += new_mob
	new_mob.reveal()
	if(trap_spawns.len > max_trap_spawns)
		var/obj/effect/nanomob/old_trap = trap_spawns[1]
		old_trap.despawn()
	return 1

/datum/controller/subsystem/mob_hunt/proc/start_check()
	if(battle_turn)		//somehow we got called mid-battle, so lets just stop now
		return
	if(red_terminal && red_terminal.ready && blue_terminal && blue_terminal.ready)
		battle_turn = pick("Красный", "Синий")
		red_terminal.atom_say("Битва начинается!")
		blue_terminal.atom_say("Битва начинается!")
		if(battle_turn == "Красный")
			red_terminal.atom_say("Ход красного игрока!")
		else if(battle_turn == "Синий")
			blue_terminal.atom_say("Ход синего игрока!")

/datum/controller/subsystem/mob_hunt/proc/launch_attack(team, raw_damage, datum/mob_type/attack_type)
	if(!team || !raw_damage)
		return
	var/obj/machinery/computer/mob_battle_terminal/target = null
	if(team == "Красный")
		target = blue_terminal
	else if(team == "Синий")
		target = red_terminal
	else
		return
	target.receive_attack(raw_damage, attack_type)

/datum/controller/subsystem/mob_hunt/proc/end_battle(loser, surrender = 0)
	var/obj/machinery/computer/mob_battle_terminal/winner_terminal = null
	var/obj/machinery/computer/mob_battle_terminal/loser_terminal = null
	if(loser == "Красный")
		loser_terminal = red_terminal
		winner_terminal = blue_terminal
	else if (loser == "Синий")
		loser_terminal = blue_terminal
		winner_terminal = red_terminal
	battle_turn = null
	winner_terminal.ready = 0
	loser_terminal.ready = 0
	if(surrender)	//surrender doesn't give exp, to avoid people just farming exp without actually doing a battle
		winner_terminal.atom_say("Ваш соперник сдался!")
	else
		var/progress_message =  winner_terminal.mob_info.gain_exp()
		winner_terminal.atom_say("[winner_terminal.team] игрок побеждает!")
		winner_terminal.atom_say(progress_message)

/datum/controller/subsystem/mob_hunt/proc/end_turn()
	red_terminal.updateUsrDialog()
	blue_terminal.updateUsrDialog()
	if(!battle_turn)
		return
	if(battle_turn == "Красный")
		battle_turn = "Синий"
		blue_terminal.atom_say("Ход синего игрока.")
	else if(battle_turn == "Синий")
		battle_turn = "Красный"
		blue_terminal.atom_say("Ход красного игрока.")
