/// R&D backup console - just saves tech levels
/obj/machinery/computer/rnd_backup
	name = "R&D backup console"
	desc = "Can be used to backup an R&D network's research data."
	icon_screen = "comm_logs" // looks good enough
	circuit = /obj/item/circuitboard/rnd_backup_console
	/// ID to autolink to, used in mapload
	var/autolink_id = null
	/// UID of the network that we use
	var/network_manager_uid = null
	/// Inserted disk
	var/obj/item/disk/rnd_backup_disk/inserted_disk


/obj/machinery/computer/rnd_backup/station
	autolink_id = "station_rnd"


/obj/machinery/computer/rnd_backup/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD


/obj/machinery/computer/rnd_backup/LateInitialize()
	for(var/obj/machinery/computer/rnd_network_controller/RNC in GLOB.rnd_network_managers)
		if(RNC.network_name == autolink_id)
			network_manager_uid = RNC.UID()
			RNC.backupconsoles += UID()

/obj/machinery/computer/rnd_backup/Destroy()
	unlink()
	eject_disk()
	return ..()


/obj/machinery/computer/rnd_backup/proc/unlink()
	network_manager_uid = null
	SStgui.update_uis(src)


/obj/machinery/computer/rnd_backup/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/disk/rnd_backup_disk) && istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(!H.transfer_item_to(used, src))
			return ITEM_INTERACT_COMPLETE

		inserted_disk = used
		to_chat(user, SPAN_NOTICE("You insert [used] into [src]."))
		SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/computer/rnd_backup/proc/eject_disk()
	if(!inserted_disk)
		return

	inserted_disk.forceMove(get_turf(src))
	inserted_disk = null


/obj/machinery/computer/rnd_backup/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)


/obj/machinery/computer/rnd_backup/ui_data(mob/user)
	var/list/data = list()
	var/has_network = FALSE
	var/list/tech_assoc_temp = list()

	data["has_disk"] = FALSE

	if(network_manager_uid)
		var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
		if(RNC)
			var/datum/research/files = RNC.research_files
			has_network = TRUE

			data["linked"] = TRUE
			data["network_name"] = RNC.network_name

			for(var/tech_id in files.known_technodes)
				if(!(tech_id in tech_assoc_temp))
					tech_assoc_temp[tech_id] = list()

				var/datum/technode/T = files.known_technodes[tech_id]
				var/list/tech_data = tech_assoc_temp[tech_id]
				tech_data["name"] = T.name
		else
			network_manager_uid = null

	if(inserted_disk)
		data["has_disk"] = TRUE
		data["disk_name"] = inserted_disk.name
		data["last_timestamp"] = inserted_disk.last_backup_time || "None"
		for(var/tech_id in inserted_disk.stored_tech_assoc)
			if(!(tech_id in tech_assoc_temp))
				tech_assoc_temp[tech_id] = list()

			var/tech_name = GLOB.rnd_technode_id_to_name[tech_id]
			var/list/tech_data = tech_assoc_temp[tech_id]
			tech_data["name"] = tech_name
			tech_data["disk_level"] = inserted_disk.stored_tech_assoc[tech_id]

	if(!has_network)
		data["linked"] = FALSE
		var/list/controllers = list()
		for(var/obj/machinery/computer/rnd_network_controller/RNC in GLOB.rnd_network_managers)
			controllers += list(list("addr" = RNC.UID(), "net_id" = RNC.network_name))

		data["controllers"] = controllers

	data["techs"] = tech_assoc_temp

	return data


/obj/machinery/computer/rnd_backup/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE

	switch(action)
		if("unlink")
			if(!network_manager_uid)
				return FALSE
			var/choice = tgui_alert(usr, "Are you SURE you want to unlink this backup console?\nYou won't be able to re-link without the network manager password", "Unlink", list("Yes", "No"))
			if(choice == "Yes")
				unlink()

		if("eject_disk")
			eject_disk()

		if("savetech2network")
			if(!network_manager_uid)
				return FALSE

			if(!inserted_disk)
				return FALSE

			var/tech = params["tech"]

			var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
			if(!RNC)
				network_manager_uid = null
				return FALSE

			var/datum/technode/T = RNC.research_files.id_to_possible_technode(tech)
			if(!T)
				return

			if(tech in RNC.research_files.known_technodes)
				to_chat(usr, SPAN_NOTICE("Node: [T.name] already in Network: <b>[RNC.network_name]</b>."))
				return FALSE



			var/choice = tgui_alert(usr, "Do you want to import this research node ([T.name]) to the network?", "Data Import", list("Yes", "No"))
			if(choice != "Yes")
				return FALSE
			RNC.research_files.unlock_technode(T)
			to_chat(usr, SPAN_NOTICE("Node: [T.name] successfully added to Network: <b>[RNC.network_name]</b>."))

		if("savetech2disk")
			if(!network_manager_uid)
				return FALSE

			if(!inserted_disk)
				return FALSE

			var/tech = params["tech"]

			var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
			if(!RNC)
				network_manager_uid = null
				return FALSE

			var/datum/technode/T = RNC.research_files.known_technodes[tech]
			if(!T)
				return

			var/choice = tgui_alert(usr, "Do you want to export this research node ([T.name]) to the disk?", "Data Export", list("Yes", "No"))
			if(choice != "Yes")
				return FALSE

			if(T.id in inserted_disk.stored_tech_assoc)
				to_chat(usr, SPAN_NOTICE("Node: [T.name] already in Disk."))
				return FALSE
			inserted_disk.stored_tech_assoc += T.id
			inserted_disk.last_backup_time = time2text(ROUND_TIME, "hh:mm:ss")

		if("saveall2network")
			if(!network_manager_uid)
				return FALSE

			if(!inserted_disk)
				return FALSE

			var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
			if(!RNC)
				network_manager_uid = null
				return FALSE

			var/choice = tgui_alert(usr, "Are you SURE you want to import all the data on the disk to the network?", "Data Import", list("Yes", "No"))
			if(choice != "Yes")
				return FALSE

			var/datum/research/files = RNC.research_files
			for(var/i in inserted_disk.stored_tech_assoc)
				var/datum/technode/T = files.id_to_possible_technode(inserted_disk.stored_tech_assoc[i])
				files.unlock_technode(T)


		if("saveall2disk")
			if(!network_manager_uid)
				return FALSE

			if(!inserted_disk)
				return FALSE

			var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
			if(!RNC)
				network_manager_uid = null
				return FALSE

			var/choice = tgui_alert(usr, "Are you SURE you want to export all the data on the network to the disk?", "Data Export", list("Yes", "No"))
			if(choice != "Yes")
				return FALSE

			var/datum/research/files = RNC.research_files
			for(var/i in files.known_technodes)
				if(!(i in inserted_disk.stored_tech_assoc))
					inserted_disk.stored_tech_assoc += i

			inserted_disk.last_backup_time = time2text(ROUND_TIME, "hh:mm:ss")

		if("linktonetworkcontroller")
			if(network_manager_uid)
				return FALSE

			var/obj/machinery/computer/rnd_network_controller/C = locateUID(params["target_controller"])
			if(istype(C, /obj/machinery/computer/rnd_network_controller))
				var/user_pass = tgui_input_text(usr, "Please enter network password", "Password Entry")
				// Check the password
				if(user_pass == C.network_password)
					network_manager_uid = C.UID()
					to_chat(usr, SPAN_NOTICE("Successfully linked to <b>[C.network_name]</b>."))

				else
					to_chat(usr, SPAN_ALERT("<b>ERROR:</b> Password incorrect."))

			else
				to_chat(usr, SPAN_ALERT("<b>ERROR:</b> Controller not found. Please file an issue report."))


/obj/machinery/computer/rnd_backup/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RndBackupConsole", name)
		ui.open()

// The disk itself - does nothing other than exist to hold variables.
/obj/item/disk/rnd_backup_disk
	name = "rnd backup disk"
	desc = "A disk for storing technology data for backup purposes."
	icon_state = "datadisk2"
	materials = list(MAT_METAL = 30, MAT_GLASS = 10)
	/// List of stored technode IDs
	var/list/stored_tech_assoc = list()
	/// Text of last backup time
	var/last_backup_time


/obj/item/disk/rnd_backup_disk/Initialize(mapload)
	. = ..()
	scatter_atom()

/obj/item/disk/rnd_backup_disk/examine(mob/user)
	. = ..()
	if(last_backup_time)
		. += "The timestamp label reads '[last_backup_time]'."
	else
		. += "The timestamp label is empty."


/obj/item/disk/rnd_backup_disk/admin
	name = "admin rnd backup disk"
	desc = "You shouldnt have this."


/obj/item/disk/rnd_backup_disk/admin/Initialize(mapload)
	. = ..()
	// Just make it all technodes - who cares
	for(var/tech_id in GLOB.rnd_technode_id_to_name)
		stored_tech_assoc += tech_id
