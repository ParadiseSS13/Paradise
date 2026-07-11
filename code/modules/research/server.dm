/obj/machinery/rnd_server
	name = "\improper R&D Server"
	desc = "A server dedicated to performing various research operations automatically."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "rd-server"
	density = TRUE
	anchored = TRUE
	idle_power_consumption = 10
	active_power_consumption = 1200
	var/active = FALSE
	/// ID to autolink to, used in mapload
	var/autolink_id = null
	/// UID of the network that we use
	var/network_manager_uid = null
	/// Do we send our points to the server or store them?
	var/send_points = FALSE
	var/efficiency_coeff = 1
	// Multiple types of points is technically supported codewise, but not supported by TGUI as its not expected, TGUI will just fetch the first in the list.
	/// How many points this generates each process() call
	var/list/point_generation = list("research" = 20) // MIXTODO - Balance later.
	/// Points stored within this server.
	var/list/stored_points = list()
	/// Total points this server has generated.
	var/list/total_points = list()
	var/obj/item/disk/tech_disk/t_disk = null
	/// How much heat does this put out?
	var/heat_amount = 25000
	/// Are we overheating?
	var/overheating = FALSE
	// What's the overheat temperature?
	var/overheat_temp = 324
	/// Used to ensure it takes a few seconds of being hot before overheating
	var/overheat_counter = 0
	/// Milla controller
	var/datum/milla_safe/rnd_server_process/milla = new()


/obj/machinery/rnd_server/Initialize(mapload)
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/rdserver(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	RefreshParts()
	update_icon_state()
	return INITIALIZE_HINT_LATELOAD


/obj/machinery/rnd_server/LateInitialize()
	for(var/obj/machinery/computer/rnd_network_controller/RNC in GLOB.rnd_network_managers)
		if(RNC.network_name == autolink_id)
			network_manager_uid = RNC.UID()
			RNC.servers += UID()

/obj/machinery/rnd_server/examine(mob/user)
	. = ..()
	var/tp = point_generation[point_generation[1]] // this feels slightly cursed
	. += SPAN_NOTICE("This machine is temperature sensitive. Any temperature colder than 273K will freeze it, while any temperature higher than [overheat_temp]K will cause it to overheat.")
	. += SPAN_NOTICE("It is generating [((tp * efficiency_coeff) / 2)] points per second")

/obj/machinery/rnd_server/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/disk))
		. = ITEM_INTERACT_COMPLETE
		if(t_disk)
			to_chat(user, "A disk is already loaded into the [src]!")
			return
		t_disk = used
		if(!user.transfer_item_to(used, src))
			return
		playsound(src, used.drop_sound, DROP_SOUND_VOLUME, ignore_walls = FALSE)
		to_chat(user, SPAN_NOTICE("You add the disk to the [src]."))
	SStgui.update_uis(src)

/obj/machinery/rnd_server/proc/points_to_disk(list/points_list)
	for(var/i in points_list)
		if(stored_points[i] <= 0)
			return // No point doing all that if we have no points to give.
		if(stored_points[i] < points_list[i])
			points_list[i] = stored_points[i]
		var/t = t_disk.load_research(points_list)
		stored_points[i] -= t
	SStgui.update_uis(src)

/// Input: Opposite of what you want: TRUE/FALSE, none will switch between the two.
/obj/machinery/rnd_server/proc/switch_mode(choice)
	var/ta = null
	if(choice)
		ta = choice
	else
		ta = send_points
	switch(ta)
		if(TRUE)
			send_points = FALSE
		if(FALSE)
			send_points = TRUE
	SStgui.update_uis(src)

/// Input: Opposite of what you want: TRUE/FALSE, none will switch between the two.
/obj/machinery/rnd_server/proc/switch_on(choice)
	var/ta = null
	if(choice)
		ta = choice
	else
		ta = active
	switch(ta)
		if(TRUE)
			active = FALSE
			change_power_mode(IDLE_POWER_USE)
		if(FALSE && !(overheating || panel_open))
			active = TRUE
			change_power_mode(ACTIVE_POWER_USE)
	update_icon_state()
	SStgui.update_uis(src)

/obj/machinery/rnd_server/update_icon_state()
	if(panel_open)
		icon_state = "[initial(icon_state)]-wires"
		return
	if(overheating)
		icon_state = "[initial(icon_state)]-bad"
		return
	if(has_power() && active)
		icon_state = "[initial(icon_state)]-active"
		return
	if(has_power())
		icon_state = "[initial(icon_state)]-on"
		return
	icon_state = "[initial(icon_state)]"


/obj/machinery/rnd_server/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/S in component_parts)
		T += S.rating
	efficiency_coeff = T

/obj/machinery/rnd_server/process()
	if(active)
		if(send_points == TRUE && !network_manager_uid)	// We cant send points to the aether if theres no connected network.
			send_points = FALSE
		for(var/i in point_generation)
			var/list/tl = point_generation[i] * (efficiency_coeff / point_generation.len)
			if(send_points == TRUE)
				var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
				RNC.research_files.addpoints(tl)
				total_points[i] = FLOOR(total_points[i] + point_generation[i], 0.1)
			if(send_points == FALSE)
				stored_points[i] = FLOOR(stored_points[i] + point_generation[i], 0.1)
				total_points[i] = FLOOR(total_points[i] + point_generation[i], 0.1)
		milla.invoke_async(src)
	SStgui.update_uis(src)

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
	if(!active)
		default_deconstruction_screwdriver(user, "RD-server-wires", "RD-server", I)
		update_icon()
		return TRUE
	else
		to_chat(user, "The [src] must be turned off to open its panel!")
		return FALSE

/obj/machinery/rnd_server/proc/unlink()
	network_manager_uid = null
	SStgui.update_uis(src)

/obj/machinery/rnd_server/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/rnd_server/proc/overheat()
	active = FALSE
	atom_say("ERROR: Heat critical!")
	change_power_mode(IDLE_POWER_USE)
	update_icon()

/obj/machinery/rnd_server/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RndServer", name)
		ui.open()


/obj/machinery/rnd_server/ui_data(mob/user)
	var/list/data = list()

	var/pgt = point_generation[1]
	var/pgv = point_generation[pgt] * (efficiency_coeff / point_generation.len) // TGUI wont display a second type of point, but it should display the first accurately.

	// Point data
	var/sp = null
	if(!stored_points[pgt])
		sp = 0
	else
		sp = stored_points[pgt]

	var/tp = null
	if(!total_points[pgt])
		tp = 0
	else
		tp = total_points [pgt]

	data["point_gen_type"] = pgt
	data["point_gen_val"] = pgv
	data["stored_points"] = sp
	data["total_points"] = tp

	data["mode"] = send_points

	if(t_disk)
		data["loaded_disk"] = t_disk
		if(t_disk.stored_research.len > 0)
			var/tdt = t_disk.stored_research[1] // As with tech_disks.dm, rather fragile but disks shouldnt have more then one kind of point.
			var/tdp = t_disk.stored_research[tdt]
			data["disk_stored_t"] = tdt
			data["disk_stored_p"] = tdp
		else
			data["disk_stored_t"] = null
			data["disk_stored_p"] = null
	else
		data["loaded_disk"] = null
		data["disk_stored_t"] = null
		data["disk_stored_p"] = null

	data["active"] = active

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

	return data


/obj/machinery/rnd_server/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	// Check against href exploits
	if(..())
		return

	. = TRUE

	switch(action)
		if("mode")
			switch_mode()

		if("swtch_on")
			switch_on()

		if("load")
			if(!t_disk || !stored_points)
				return
			var/amnt = input(usr, "Please enter amount to transfer", "Disk Transfer", 0)
			var/p_type = stored_points[1]
			if(amnt < 0 || !amnt)
				return // No.
			var/list/to_send = list(p_type)
			to_send[p_type] = amnt
			points_to_disk(to_send)

		if("eject_disk")
			if(t_disk)
				t_disk.forceMove(loc)
				if(Adjacent(ui.user) && !issilicon(ui.user))
					ui.user.put_in_hands(t_disk)
				t_disk = null

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
			SStgui.update_uis(src)

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
	active = TRUE
	send_points = TRUE


/datum/milla_safe/rnd_server_process

/datum/milla_safe/rnd_server_process/on_run(obj/machinery/rnd_server/server) // Generously donated from ai_resource.dm, along with any other heat stuff.
	var/turf/simulated/L = get_turf(server)
	if(!istype(L))
		return
	var/datum/gas_mixture/env = get_turf_air(L)
	var/transfer_moles = 0.25 * env.total_moles()
	var/datum/gas_mixture/removed = env.remove(transfer_moles)
	if(!removed)
		server.overheat_counter++
		if(server.overheat_counter >= 5)
			server.overheat()
		return
	var/heat_capacity = removed.heat_capacity()
	if(heat_capacity)
		removed.set_temperature(removed.temperature() + server.heat_amount / heat_capacity)
	env.merge(removed)
	// Heat check
	if(env.temperature() > server.overheat_temp || env.temperature() < 273) // If the temperature is outside 0-100C...
		// Turn the server off due to temperature problems
		server.overheat_counter++
		if(server.overheat_counter >= 5)
			server.overheat()
		return
	if(server.overheat_counter)
		server.overheat_counter--
