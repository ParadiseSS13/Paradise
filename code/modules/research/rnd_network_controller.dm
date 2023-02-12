GLOBAL_LIST_EMPTY(rnd_network_managers)

/obj/machinery/computer/rnd_network_controller
	name = "\improper R&D network manager"
	desc = "Use this to manage an R&D network and its connected servers"
	icon_screen = "rnd_netmanager"
	icon_keyboard = "rd_key"
	light_color = LIGHT_COLOR_FADEDPURPLE
	circuit = /obj/item/circuitboard/rdservercontrol

	/// List of R&D servers connected. Soft-refs only.
	var/list/servers = list()
	/// List of R&D consoles connected. Soft-refs only.
	var/list/consoles = list()
	/// List of mechfabs connected. Soft-refs only.
	var/list/mechfabs = list()
	/// The files for all the research data on this system
	var/datum/research/research_files
	/// The link ID of this console, used for map purposes
	var/network_name = null

/obj/machinery/computer/rnd_network_controller/Initialize()
	. = ..()
	GLOB.rnd_network_managers += src
	research_files = new

/obj/machinery/computer/rnd_network_controller/Destroy()
	GLOB.rnd_network_managers -= src

	// Inform admins - this is kinda round impacting
	if(usr)
		message_admins("[key_name_admin(usr)] destroyed [src] at [src ? "[get_location_name(src, TRUE)] [COORD(src)]" : "nonexistent location"] [ADMIN_JMP(src)]. If this was a non-antag please investigate as it has major round implications.")

	/*
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
	*/

	QDEL_NULL(research_files)

	return ..()


/obj/machinery/computer/rnd_network_controller/screwdriver_act(mob/user, obj/item/I)
	var/areyousure = alert(user, "Disassembling this console will wipe its networks RnD progress from this round. If you are doing this as a non-antag, expect a bollocking.\n\nAre you sure?", "Think for a moment", "Yes", "No")
	if(areyousure != "Yes")
		return TRUE // Dont attack the console, pretend we did something

	. = ..()


// Presets

/obj/machinery/computer/rnd_network_controller/station
	network_name = "station_rnd"
