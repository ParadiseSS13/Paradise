GLOBAL_LIST_EMPTY(rnd_network_managers)

/obj/machinery/computer/rnd_network_controller
	// Dont call this R&D, you break tooltips from the &
	name = "\improper RnD network manager"
	desc = "Use this to manage an R&D network and its connected servers."
	icon_screen = "rnd_netmanager"
	icon_keyboard = "rd_key"
	light_color = LIGHT_COLOR_FADEDPURPLE
	circuit = /obj/item/circuitboard/rnd_network_controller

	/// List of R&D servers connected. Soft-refs only.
	var/list/servers = list()
	/// List of R&D consoles connected. Soft-refs only.
	var/list/consoles = list()
	/// List of mechfabs connected. Soft-refs only.
	var/list/mechfabs = list()
	/// List of backup consoles. Soft-refs only.
	var/list/backupconsoles = list()
	/// The files for all the research data on this system
	var/datum/research/research_files
	/// The link ID of this console, used for map purposes
	var/network_name = null
	/// The network password for this device
	var/network_password

/obj/machinery/computer/rnd_network_controller/Initialize(mapload)
	. = ..()
	GLOB.rnd_network_managers += src
	research_files = new
	network_password = GenerateKey()

	// Make sure that name isnt already in use
	if(network_name)
		network_name = trim(network_name)

		if(name_check(network_name))
			var/myuid = UID()
			stack_trace("[src] at [x],[y],[z] tried to init with a network name of [network_name] when its already in use. Name has been randomised to [myuid]")
			network_name = myuid

	if(!network_name)
		network_name = UID()

/**
  * Name sanity check
  *
  * Makes sure the target network name isnt already in use. Returns TRUE or FALSE depending on that criteria.
  * Arguments:
  * * pending_name - The name to check
  */
/obj/machinery/computer/rnd_network_controller/proc/name_check(pending_name)
	var/list/all_names = list()

	for(var/obj/machinery/computer/rnd_network_controller/RNC in GLOB.rnd_network_managers)
		if(RNC == src)
			continue
		all_names += RNC.network_name

	return (pending_name in all_names)

/obj/machinery/computer/rnd_network_controller/Destroy()
	GLOB.rnd_network_managers -= src

	// Inform admins - this is kinda round impacting
	if(usr)
		message_admins("[key_name_admin(usr)] destroyed [src] at [src ? "[get_location_name(src, TRUE)] [COORD(src)]" : "nonexistent location"] [ADMIN_JMP(src)]. If this was a non-antag please investigate as it has major round implications.")

	// Unlink all attached servers
	for(var/server_uid in servers)
		var/obj/machinery/r_n_d/server/S = locateUID(server_uid)
		if(!S)
			continue

		S.unlink()

	// Unlink all attached consoles
	for(var/console_uid in consoles)
		var/obj/machinery/computer/rdconsole/RDC = locateUID(console_uid)
		if(!RDC)
			continue

		RDC.unlink()

	// Unlink all attached mechfabs
	for(var/mechfab_uid in mechfabs)
		var/obj/machinery/mecha_part_fabricator/MF = locateUID(mechfab_uid)
		if(!MF)
			continue

		MF.unlink()

	// Unlink all attached backup consoles
	for(var/backupconsoles_uid in backupconsoles)
		var/obj/machinery/computer/rnd_backup/BC = locateUID(backupconsoles_uid)
		if(!BC)
			continue

		BC.unlink()

	QDEL_NULL(research_files)

	return ..()


/obj/machinery/computer/rnd_network_controller/screwdriver_act(mob/user, obj/item/I)
	var/areyousure = tgui_alert(user, "Disassembling this console will wipe its network's RnD progress from this round. If you are doing this as a non-antag, expect a bollocking.\n\nAre you sure?", "Think for a moment", list("Yes", "No"))
	if(areyousure != "Yes")
		return TRUE // Dont attack the console, pretend we did something

	return ..()


/obj/machinery/computer/rnd_network_controller/attack_hand(mob/user)
	ui_interact(user)


/obj/machinery/computer/rnd_network_controller/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RndNetController", name)
		ui.open()


/obj/machinery/computer/rnd_network_controller/ui_data(mob/user)
	var/list/data = list()

	data["network_password"] = network_password
	data["network_name"] = network_name

	var/list/devices = list()

	for(var/server_uid in servers)
		var/obj/machinery/r_n_d/server/S = locateUID(server_uid)
		if(!S)
			servers -= server_uid
			continue
		devices += list(list("name" = S.name, "id" = S.UID(), "dclass" = "SRV"))


	for(var/console_uid in consoles)
		var/obj/machinery/computer/rdconsole/RDC = locateUID(console_uid)
		if(!RDC)
			consoles -= console_uid
			continue
		devices += list(list("name" = RDC.name, "id" = RDC.UID(), "dclass" = "RDC"))


	for(var/mechfab_uid in mechfabs)
		var/obj/machinery/mecha_part_fabricator/MF = locateUID(mechfab_uid)
		if(!MF)
			mechfabs -= mechfab_uid
			continue
		devices += list(list("name" = MF.name, "id" = MF.UID(), "dclass" = "MFB"))

	for(var/backup_uid in backupconsoles)
		var/obj/machinery/computer/rnd_backup/RB = locateUID(backup_uid)
		if(!RB)
			backupconsoles -= backup_uid
			continue
		devices += list(list("name" = RB.name, "id" = RB.UID(), "dclass" = "BCK"))

	data["devices"] = devices

	var/list/designs = list()

	// Handle design blacklisting and unblacklisting
	for(var/datum/design/D in research_files.possible_designs)
		if(!(D.id in research_files.known_designs) && !(D.id in research_files.blacklisted_designs))
			continue

		var/list/design_data = list()
		design_data["name"] = D.name
		design_data["id"] = D.id
		design_data["blacklisted"] = (D.id in research_files.blacklisted_designs)
		design_data["uid"] = D.UID()

		designs += list(design_data)

	data["designs"] = designs

	return data


/obj/machinery/computer/rnd_network_controller/ui_act(action, list/params)
	if(..())
		return

	. = TRUE

	switch(action)
		// Set network name
		if("network_name")
			var/new_name = tgui_input_text(usr, "Please enter a new network ID", "Network ID", network_name)
			if(!Adjacent(usr) || !new_name)
				return

			new_name = trim(new_name)

			if(length(new_name) == 0)
				return

			if(name_check(new_name))
				to_chat(usr, "<span class='warning'>Error, network name <code>[new_name]</code> already in use.</span>")
				return

			to_chat(usr, "<span class='notice'>Network name changed from <code>[network_name]</code> to <code>[new_name]</code>.</span>")
			network_name = new_name

		if("blacklist_design")
			var/design_uid = params["d_uid"]
			var/datum/design/D = locateUID(design_uid)

			// If null design, ignore
			if(!istype(D))
				return

			// If not one of our designs, disallow
			if(!(D.id in research_files.known_designs))
				return

			message_admins("[key_name_admin(usr)] blacklisted [D.name] from the R&D network [network_name].")
			log_game("[key_name(usr)] blacklisted [D.name] from the R&D network [network_name].")
			research_files.known_designs -= D.id
			research_files.blacklisted_designs += D.id
			research_files.RefreshResearch()

		if("unblacklist_design")
			var/design_uid = params["d_uid"]
			var/datum/design/D = locateUID(design_uid)

			// If null design, ignore
			if(!istype(D, /datum/design))
				return

			// If not one of our designs, disallow
			if(!(D.id in research_files.blacklisted_designs))
				return

			message_admins("[key_name_admin(usr)] unblacklisted [D.name] from the R&D network [network_name].")
			log_game("[key_name(usr)] unblacklisted [D.name] from the R&D network [network_name].")
			research_files.unblacklisted_designs += D.id
			research_files.blacklisted_designs -= D.id
			research_files.RefreshResearch()

		// Set network password
		if("network_password")
			var/new_password = tgui_input_text(usr, "Please enter a new network ID", "Network ID", network_password)
			if(!Adjacent(usr))
				return
			to_chat(usr, "<span class='notice'>Network password changed from <code>[network_password]</code> to <code>[new_password]</code>.</span>")
			network_password = new_password

		// Remove a device
		if("unlink_device")
			switch(params["dclass"])
				if("SRV")
					if(!(params["uid"] in servers))
						message_admins("[key_name_admin(usr)] attempted a href exploit with [src]")
						return

					var/choice = tgui_alert(usr, "Are you SURE you want to unlink this device?", "Unlink", list("Yes", "No"))
					if(choice != "Yes" || !Adjacent(usr))
						return

					var/obj/machinery/r_n_d/server/S = locateUID(params["uid"])
					servers -= params["uid"]
					if(S)
						S.unlink()
						to_chat(usr, "<span class='notice'>Successfully unlinked <code>[S.name]</code> from the network <code>[network_name]</code>")
						return

				if("RDC")
					if(!(params["uid"] in consoles))
						message_admins("[key_name_admin(usr)] attempted a href exploit with [src]")
						return

					var/choice = tgui_alert(usr, "Are you SURE you want to unlink this device?", "Unlink", list("Yes", "No"))
					if(choice != "Yes" || !Adjacent(usr))
						return

					var/obj/machinery/computer/rdconsole/RDC = locateUID(params["uid"])
					consoles -= params["uid"]
					if(RDC)
						RDC.unlink()
						to_chat(usr, "<span class='notice'>Successfully unlinked <code>[RDC.name]</code> from the network <code>[network_name]</code>")
						return

				if("MFB")
					if(!(params["uid"] in mechfabs))
						message_admins("[key_name_admin(usr)] attempted a href exploit with [src]")
						return

					var/choice = tgui_alert(usr, "Are you SURE you want to unlink this device?", "Unlink", list("Yes", "No"))
					if(choice != "Yes" || !Adjacent(usr))
						return

					var/obj/machinery/mecha_part_fabricator/MPF = locateUID(params["uid"])
					mechfabs -= params["uid"]
					if(MPF)
						MPF.unlink()
						to_chat(usr, "<span class='notice'>Successfully unlinked <code>[MPF.name]</code> from the network <code>[network_name]</code>")
						return

				if("BCK")
					if(!(params["uid"] in backupconsoles))
						message_admins("[key_name_admin(usr)] attempted a href exploit with [src]")
						return

					var/choice = tgui_alert(usr, "Are you SURE you want to unlink this device?", "Unlink", list("Yes", "No"))
					if(choice != "Yes" || !Adjacent(usr))
						return

					var/obj/machinery/computer/rnd_backup/RB = locateUID(params["uid"])
					backupconsoles -= params["uid"]
					if(RB)
						RB.unlink()
						to_chat(usr, "<span class='notice'>Successfully unlinked <code>[RB.name]</code> from the network <code>[network_name]</code></span>")
						return


// Presets
/obj/machinery/computer/rnd_network_controller/station
	network_name = "station_rnd"

/obj/machinery/computer/rnd_network_controller/golems
	network_name = "golems_rnd"
