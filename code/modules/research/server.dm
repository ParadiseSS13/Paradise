/obj/machinery/r_n_d/server
	name = "RnD Server"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-off"
	/// ID to autolink to, used in mapload
	var/autolink_id = null
	/// UID of the network that we use
	var/network_manager_uid = null
	/// Is this server currently working
	var/working = TRUE
	/// How many process cycles to wait before producing heat
	var/heat_cycle_delay = 5
	/// Counter of how many process cycles we are in before heating again
	var/heat_cycle_counter = 0
	/// Pointgen scale - scales based on the scanning module rating
	var/pointgen_scale = 1
	/// Points to generate per cycle
	var/points_per_cycle = 20
	/// How much heat to throw into the room
	var/heating_power = 50000
	/// How many points we made last cycle
	var/points_last_cycle = 0


/obj/machinery/r_n_d/server/Initialize(mapload)
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/rdserver(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	RefreshParts()
	return INITIALIZE_HINT_LATELOAD


/obj/machinery/r_n_d/server/LateInitialize()
	for(var/obj/machinery/computer/rnd_network_controller/RNC in GLOB.rnd_network_managers)
		if(RNC.network_name == autolink_id)
			network_manager_uid = RNC.UID()
			RNC.servers += UID()


/obj/machinery/r_n_d/server/RefreshParts()
	var/gain = 0
	for(var/obj/item/stock_parts/scanning_module/SM in component_parts)
		gain = SM.rating

	pointgen_scale = (gain / 2) // Doubles with bluespace parts


/obj/machinery/r_n_d/server/Destroy()
	var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
	if(RNC)
		// Unlink us
		RNC.servers -= UID()

	return ..()


/obj/machinery/r_n_d/server/update_icon_state()
	if(stat & NOPOWER)
		icon_state = "RD-server-off"
	else
		icon_state = "RD-server-on"


/obj/machinery/r_n_d/server/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/r_n_d/server/process()
	if(!has_power())
		return

	if(prob(3))
		playsound(loc, "computer_ambience", 50, 1)

	if(!network_manager_uid)
		return

	// See if we have a host
	var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
	if(!RNC)
		network_manager_uid = null
		return null

	// ITS MATHS TIME
	var/pointscale_tempdiff = 0

	var/datum/gas_mixture/environment = loc.return_air()
	switch(environment.temperature)
		if(0 to T0C) // -273.15C to 0C
			pointscale_tempdiff = 1 // Full efficiency
		if(T0C to (T0C + 5))
			pointscale_tempdiff = 0.5 // Half efficiency
		if((T0C + 5) to (T0C + 15))
			pointscale_tempdiff = 0.1 // Shit efficiency - servers like the cold!

		// If the server temperature is >15C, it wont do any work

	// This needs tweaks
	var/points_to_generate = (points_per_cycle * pointgen_scale) * pointscale_tempdiff
	RNC.research_files.research_points += points_to_generate
	points_last_cycle = points_to_generate

	heat_cycle_counter++

	use_power(PW_CHANNEL_EQUIPMENT, 1000)

	// Warm the room
	if(heat_cycle_counter > heat_cycle_delay)
		produce_heat(10000) // The R&D servers run intel
		heat_cycle_counter = 0


/obj/machinery/r_n_d/server/proc/produce_heat(heat_amt)
	if(!(stat & (NOPOWER|BROKEN))) // Blatantly stolen from space heater.
		var/turf/simulated/L = loc
		if(istype(L))
			var/datum/gas_mixture/env = L.return_air()
			if(env.temperature < (heat_amt + T0C))

				var/transfer_moles = 0.25 * env.total_moles()

				var/datum/gas_mixture/removed = env.remove(transfer_moles)

				if(removed)

					var/heat_capacity = removed.heat_capacity()
					if(heat_capacity == 0 || heat_capacity == null)
						heat_capacity = 1
					removed.temperature = min((removed.temperature * heat_capacity + heating_power) / heat_capacity, 1000)

				env.merge(removed)
				air_update_turf()


/obj/machinery/r_n_d/server/proc/unlink()
	network_manager_uid = null
	SStgui.update_uis(src)

/obj/machinery/r_n_d/server/attack_hand(mob/user)
	ui_interact(user)


/obj/machinery/r_n_d/server/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "RndServer", name, 600, 500, master_ui, state)
		ui.open()


/obj/machinery/r_n_d/server/ui_data(mob/user)
	var/list/data = list()

		// Are we on or not
	data["active"] = working


	var/datum/gas_mixture/environment = loc.return_air()
	if(environment?.temperature)
		data["temperature"] = environment.temperature
	else
		data["temperature"] = 0


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
	data["points_last_cycle"] = points_last_cycle
	data["network_points"] = RNC?.research_files.research_points || 0

	return data


/obj/machinery/r_n_d/server/ui_act(action, list/params)
	// Check against href exploits
	if(..())
		return

	. = TRUE

	switch(action)
		if("toggle_active")
			working = !working
			update_icon()

		if("unlink")
			if(!network_manager_uid)
				return
			var/choice = alert(usr, "Are you SURE you want to unlink this server?\nYou wont be able to re-link without the network password", "Unlink","Yes","No")
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

				var/wifi_pass = input(usr, "Please enter network password","Password Entry") // ayo whats your wifi pass
				// Check the password
				if(wifi_pass == RNC.network_password)
					network_manager_uid = RNC.UID()
					RNC.servers += UID()
					to_chat(usr, "<span class='notice'>Successfully linked to <b>[RNC.network_name]</b>.</span>")
				else
					to_chat(usr, "<span class='alert'><b>ERROR:</b> Password incorrect.</span>")

			else
				to_chat(usr, "<span class='alert'><b>ERROR:</b> Network manager not found. Please file an issue report.</span>")


// PRESETS //

/obj/machinery/r_n_d/server/station
	autolink_id = "station_rnd"

