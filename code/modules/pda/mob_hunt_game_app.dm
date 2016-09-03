
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

/datum/data/pda/app/mob_hunter_game/start()
	..()
	processing_objects.Add(pda)

/datum/data/pda/app/mob_hunter_game/stop()
	..()
	processing_objects.Remove(pda)

/datum/data/pda/app/mob_hunter_game/proc/scan_nearby()
	if(!mob_hunt_server)
		return

/datum/data/pda/app/mob_hunter_game/proc/connect()
	if(!mob_hunt_server || !mob_hunt_server.server_status)
		//show a message about the server being unavailable (because it doesn't exist / didn't get set to the global var / is offline)
		return 0
	mob_hunt_server.connected_clients += src
	return 1

/datum/data/pda/app/mob_hunter_game/proc/disconnect(reason_message = null)
	mob_hunt_server.connected_clients -= src
	//show a disconnect message if we were disconnected involuntarily (message argument provided)

/datum/data/pda/app/mob_hunter_game/program_process()
	if(!mob_hunt_server)
		return null
	for(var/obj/effect/nanomob/N in range(3, pda.loc))
		//TO-DO: show the mob (ideally only to the holder of the PDA, but we'll settle for the t-ray magic of showing everyone for right now)
		if(N.invisibility == 101)
			N.invisibility = 0
			spawn(30)
				if(N)
					N.invisibility = 101

/datum/data/pda/app/mob_hunter_game/proc/register_capture(datum/mob_hunt/captured)
	if(!captured)
		return 0
	my_collection.Add(captured)
	return 1

/datum/data/pda/app/mob_hunter_game/update_ui(mob/user as mob, list/data)
	if(!my_collection.len)
		data["no_collecton"] = 1
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
						"type1" = mob_info.primary_type,
						"type2" = mob_info.secondary_type,
						"sprite" = "[mob_info.icon_state_normal].png"
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
	var/obj/item/weapon/nanomob_card/card = new/obj/item/weapon/nanomob_card(null)
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
		if("Connect")
			connect()
		if("Disconnect")
			disconnect()
		if("Transfer")
			print_card()