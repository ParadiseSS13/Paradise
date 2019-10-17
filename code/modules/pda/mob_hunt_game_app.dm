
/*
	This stuff isn't included with in core_apps.dm because it is so distinct and would end up making the file huge (more than it already is).
	I put it in it's own file in order to help it stay organized and easier to locate the procs and such.
	For reference, the other Nano-mob Hunter GO files are in /code/game/modules/arcade/mob_hunt
*/

/datum/data/pda/app/mob_hunter_game
	name = "Nano-Mob Hunter GO"
	icon = "gamepad"
	template = "pda_mob_hunt"
	category = "Games"

	var/list/my_collection = list()
	var/current_index = 0
	var/connected = 0
	var/hacked = 0		//if set, this cartridge is able to spawn trap mobs from its collection (set via emag_act on the cartridge)
	var/catch_mod = 0	//used to adjust the likelihood of a mob running from this client, a negative value means it is less likely to run (support for temporary bonuses)
	var/wild_captures = 0		//used to track the total number of mobs captured from the wild (does not count card mobs) by this client
	var/scan_range = 3			//maximum distance (in tiles) from which the client can reveal nearby mobs

/datum/data/pda/app/mob_hunter_game/start()
	..()
	START_PROCESSING(SSobj, pda)

/datum/data/pda/app/mob_hunter_game/stop()
	..()
	disconnect("Program Terminated")
	STOP_PROCESSING(SSobj, pda)

/datum/data/pda/app/mob_hunter_game/proc/scan_nearby()
	if(!SSmob_hunt || !connected)
		return
	for(var/turf/T in range(scan_range, get_turf(pda)))
		for(var/obj/effect/nanomob/N in T.contents)
			if(src in N.clients_encountered)
				//hide the mob
				N.conceal()
			else
				//reveal the mob
				N.reveal()

/datum/data/pda/app/mob_hunter_game/proc/reconnect()
	if(!SSmob_hunt || !SSmob_hunt.server_status || connected)
		//show a message about the server being unavailable (because it doesn't exist / didn't get set to the global var / is offline)
		return 0
	SSmob_hunt.connected_clients += src
	connected = 1
	if(pda)
		pda.audible_message("[bicon(pda)] Connection established. Capture all of the mobs, [pda.owner ? pda.owner : "hunter"]!", null, 2)
	return 1

/datum/data/pda/app/mob_hunter_game/proc/get_player()
	if(!pda)
		return null
	if(ishuman(pda.loc))
		var/mob/living/carbon/human/H = pda.loc
		return H
	return null

/datum/data/pda/app/mob_hunter_game/proc/disconnect(reason = null)
	if(!SSmob_hunt || !connected)
		return
	SSmob_hunt.connected_clients -= src
	for(var/obj/effect/nanomob/N in (SSmob_hunt.normal_spawns + SSmob_hunt.trap_spawns))
		N.conceal(list(get_player()))
	connected = 0
	//show a disconnect message if we were disconnected involuntarily (reason argument provided)
	if(pda && reason)
		pda.audible_message("[bicon(pda)] Disconnected from server. Reason: [reason].", null, 2)

/datum/data/pda/app/mob_hunter_game/program_process()
	if(!SSmob_hunt || !connected)
		return
	scan_nearby()

/datum/data/pda/app/mob_hunter_game/proc/register_capture(datum/mob_hunt/captured, wild = 0)
	if(!captured)
		return 0
	my_collection.Add(captured)
	if(wild)
		wild_captures++
	return 1

/datum/data/pda/app/mob_hunter_game/update_ui(mob/user, list/data)
	if(!SSmob_hunt || !(src in SSmob_hunt.connected_clients))
		data["connected"] = 0
	else
		data["connected"] = 1
	data["wild_captures"] = wild_captures
	data["no_collection"] = 0
	if(!my_collection.len)
		data["no_collection"] = 1
		return
	var/datum/mob_hunt/mob_info
	if(!current_index)
		current_index = 1
	if(current_index > my_collection.len)
		current_index = 1
	if(current_index < 1)
		current_index = my_collection.len
	mob_info = my_collection[current_index]
	var/list/entry = list(
						"nickname" = mob_info.nickname,
						"real_name" = mob_info.mob_name,
						"level" = mob_info.level,
						"type1" = mob_info.get_type1(),
						"type2" = mob_info.get_type2(),
						"sprite" = "[mob_info.icon_state_normal].png",
						"is_hacked" = hacked
						)
	if(mob_info.is_shiny)
		entry["sprite"] = "[mob_info.icon_state_shiny].png"
	data["entry"] = entry

/datum/data/pda/app/mob_hunter_game/proc/assign_nickname()
	if(!my_collection.len)
		return
	var/datum/mob_hunt/mob_info = my_collection[current_index]
	var/old_name = mob_info.mob_name
	if(mob_info.nickname)
		old_name = mob_info.nickname
	mob_info.nickname = input("Give a nickname to [old_name]?", "Nickname", old_name)

/datum/data/pda/app/mob_hunter_game/proc/release()
	if(!my_collection.len)
		return
	if(alert("Are you sure you want to release this mob back into the wild?", "Confirm Release", "Yes", "No") == "Yes")
		remove_mob()

/datum/data/pda/app/mob_hunter_game/proc/print_card()
	if(!pda || !my_collection.len)
		return
	var/obj/item/nanomob_card/card = new/obj/item/nanomob_card(null)
	var/datum/mob_hunt/mob_info = my_collection[current_index]
	card.mob_data = mob_info
	card.update_info()
	card.forceMove(get_turf(pda))
	remove_mob()

/datum/data/pda/app/mob_hunter_game/proc/remove_mob()
	if(!my_collection.len)
		return
	my_collection.Remove(my_collection[current_index])
	if(current_index > my_collection.len)
		current_index = my_collection.len

/datum/data/pda/app/mob_hunter_game/proc/set_trap()
	if(!my_collection.len || !pda || !hacked)
		return
	var/datum/mob_hunt/bait = my_collection[current_index]
	bait = bait.type
	new bait(1, get_turf(pda))

/datum/data/pda/app/mob_hunter_game/Topic(href, list/href_list)
	switch(href_list["choice"])
		if("Rename")
			assign_nickname()
		if("Release")
			release()
		if("Next")
			current_index++
			if(current_index > my_collection.len)
				current_index = 1
		if("Prev")
			current_index--
			if(current_index < 1)
				current_index = my_collection.len
		if("Reconnect")
			reconnect()
		if("Disconnect")
			disconnect()
		if("Transfer")
			print_card()
		if("Set_Trap")
			set_trap()