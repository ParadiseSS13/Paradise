/obj/machinery/rnd_server
	name = "\improper R&D Server"
	desc = "A server dedicated to performing various research operations automatically."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-off"
	var/active = FALSE
	/// ID to autolink to, used in mapload
	var/autolink_id = null
	/// UID of the network that we use
	var/network_manager_uid = null
	var/efficiency_coeff = 1
	/// How many points this generates each process() call
	var/point_generation = 20 // MIXTODO - Balance later.
	/// Total points this server has generated
	var/total_points = 0
	var/original_desc = "A server dedicated to performing various research operations automatically."

/obj/machinery/rnd_server/Initialize(mapload)
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/rdserver(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	RefreshParts()
	return INITIALIZE_HINT_LATELOAD


/obj/machinery/rnd_server/LateInitialize()
	for(var/obj/machinery/computer/rnd_network_controller/RNC in GLOB.rnd_network_managers)
		if(RNC.network_name == autolink_id)
			network_manager_uid = RNC.UID()
			RNC.servers += UID()


/obj/machinery/rnd_server/update_icon_state()
	if(stat & NOPOWER)
		icon_state = "RD-server-off"
	else
		icon_state = "RD-server-on"

/obj/machinery/rnd_server/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/S in component_parts)
		T += S.rating
	efficiency_coeff = T
	desc = original_desc + "\n [SPAN_NOTICE("It is generating [((point_generation * efficiency_coeff) / 2)] points per second")]"

/obj/machinery/rnd_server/process()
	var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
	var/tp = (point_generation * efficiency_coeff)
	total_points += tp
	var/list/tl = list("research" = tp)
	RNC.research_files.addpoints(tl)

/obj/machinery/rnd_server/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/rnd_server/crowbar_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	default_deconstruction_crowbar(user, I)


/obj/machinery/rnd_server/screwdriver_act(mob/living/user, obj/item/I)
	default_deconstruction_screwdriver(user, "RD-server-on_t", "RD-server-on", I)
	return TRUE

/obj/machinery/rnd_server/proc/unlink()
	network_manager_uid = null
	SStgui.update_uis(src)

/obj/machinery/rnd_server/attack_hand(mob/user)
	ui_interact(user)


/obj/machinery/rnd_server/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RndServer", name)
		ui.open()


/obj/machinery/rnd_server/ui_data(mob/user)
	var/list/data = list()

	var/obj/machinery/computer/rnd_network_controller/RNC
	if(network_manager_uid)
		RNC = locateUID(network_manager_uid)

	if(!network_manager_uid || !RNC)
		network_manager_uid = null
		data["network_name"] = null

		var/list/controllers = list()
		for(var/obj/machinery/computer/rnd_network_controller/RNC2 in GLOB.rnd_network_managers)
			if(atoms_share_level(RNC2, src))
				controllers += list(list("addr" = "\ref[RNC2]", "netname" = RNC2.network_name))

		data["controllers"] = controllers

		return data // Short circuit here, we aint linked

	// Network metadata
	data["network_name"] = RNC.network_name
	data["linked_core_addr"] = "\ref[RNC]"
	data["total_points"] = total_points
	data["point_gen"] = ((point_generation * efficiency_coeff) / 2) // points per second

	return data


/obj/machinery/rnd_server/ui_act(action, list/params)
	// Check against href exploits
	if(..())
		return

	. = TRUE

	switch(action)
		if("unlink")
			if(!network_manager_uid)
				return
			var/choice = tgui_alert(usr, "Are you SURE you want to unlink this server?\nYou won't be able to re-link without the network password", "Unlink", list("Yes", "No"))
			if(choice == "Yes")
				// To the person who asks "Why not call unlink() here"
				// Well, all it does is null the network manager UID and update the ui
				// and we already update the UI at the end of this
				var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
				if(RNC)
					RNC.servers -= UID()
				network_manager_uid = null

		// You should only be able to link if its not linked, to prevent weirdness
		if("link")
			if(network_manager_uid)
				return

			var/obj/machinery/computer/rnd_network_controller/RNC = locate(params["addr"])
			if(istype(RNC, /obj/machinery/computer/rnd_network_controller))
				// No linking unless were on the same Z
				if(!atoms_share_level(RNC, src))
					return

				var/wifi_pass = tgui_input_text(usr, "Please enter network password","Password Entry") // ayo whats your wifi pass
				// Check the password
				if(wifi_pass == RNC.network_password)
					network_manager_uid = RNC.UID()
					RNC.servers += UID()
					to_chat(usr, SPAN_NOTICE("Successfully linked to <b>[RNC.network_name]</b>."))
				else
					to_chat(usr, SPAN_ALERT("<b>ERROR:</b> Password incorrect."))

			else
				to_chat(usr, SPAN_ALERT("<b>ERROR:</b> Network manager not found. Please file an issue report."))



// PRESETS //

/obj/machinery/rnd_server/station
	autolink_id = "station_rnd"
