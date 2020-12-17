/obj/machinery/computer/sm_monitor
	name = "supermatter monitoring console"
	desc = "Used to monitor supermatter shards."
	icon_keyboard = "power_key"
	icon_screen = "smmon_0"
	circuit = /obj/item/circuitboard/sm_monitor
	light_color = LIGHT_COLOR_YELLOW
	/// Cache-list of all supermatter shards
	var/list/supermatters
	/// Last status of the active supermatter for caching purposes
	var/last_status
	/// Reference to the active shard
	var/obj/machinery/power/supermatter_shard/active

/obj/machinery/computer/sm_monitor/Destroy()
	active = null
	return ..()

/obj/machinery/computer/sm_monitor/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/sm_monitor/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/sm_monitor/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SupermatterMonitor", name, 600, 325, master_ui, state)
		ui.open()

/obj/machinery/computer/sm_monitor/ui_data(mob/user)
	var/list/data = list()

	if(istype(active))
		var/turf/T = get_turf(active)
		// If we somehow delam during this proc, handle it somewhat
		if(!T)
			active = null
			refresh()
			return
		var/datum/gas_mixture/air = T.return_air()
		if(!air)
			active = null
			return

		data["active"] = TRUE
		data["SM_integrity"] = active.get_integrity()
		data["SM_power"] = active.power
		data["SM_ambienttemp"] = air.temperature
		data["SM_ambientpressure"] = air.return_pressure()
		//data["SM_EPR"] = round((air.total_moles / air.group_multiplier) / 23.1, 0.01)
		var/other_moles = air.total_trace_moles()
		var/TM = air.total_moles()
		if(TM)
			data["SM_gas_O2"] = round(100*air.oxygen/TM, 0.01)
			data["SM_gas_CO2"] = round(100*air.carbon_dioxide/TM, 0.01)
			data["SM_gas_N2"] = round(100*air.nitrogen/TM, 0.01)
			data["SM_gas_PL"] = round(100*air.toxins/TM, 0.01)
			if(other_moles)
				data["SM_gas_OTHER"] = round(100 * other_moles / TM, 0.01)
			else
				data["SM_gas_OTHER"] = 0
		else
			data["SM_gas_O2"] = 0
			data["SM_gas_CO2"] = 0
			data["SM_gas_N2"] = 0
			data["SM_gas_PH"] = 0
			data["SM_gas_OTHER"] = 0
	else
		var/list/SMS = list()
		for(var/I in supermatters)
			var/obj/machinery/power/supermatter_shard/S = I
			var/area/A = get_area(S)
			if(!A)
				continue

			SMS.Add(list(list(
				"area_name" = A.name,
				"integrity" = S.get_integrity(),
				"uid" = S.UID()
			)))

		data["active"] = FALSE
		data["supermatters"] = SMS

	return data

/**
  * Supermatter List Refresher
  *
  * This proc loops through the list of supermatters in the atmos SS and adds them to this console's cache list
  */
/obj/machinery/computer/sm_monitor/proc/refresh()
	supermatters = list()
	var/turf/T = get_turf(ui_host()) // Get the UI host incase this ever turned into a supermatter monitoring module for AIs to use or something
	if(!T)
		return
	for(var/obj/machinery/power/supermatter_shard/S in SSair.atmos_machinery)
		// Delaminating, not within coverage, not on a tile.
		if(!(is_station_level(S.z) || is_mining_level(S.z) || atoms_share_level(S, T) || !istype(S.loc, /turf/simulated/)))
			continue
		supermatters.Add(S)

	if(!(active in supermatters))
		active = null

/obj/machinery/computer/sm_monitor/process()
	if(stat & (NOPOWER|BROKEN))
		return FALSE

	if(active)
		var/new_status = active.get_status()
		if(last_status != new_status)
			last_status = new_status
			if(last_status == SUPERMATTER_ERROR)
				last_status = SUPERMATTER_INACTIVE
			icon_screen = "smmon_[last_status]"
			update_icon()

	return TRUE

/obj/machinery/computer/sm_monitor/ui_act(action, params)
	if(..())
		return

	if(stat & (BROKEN|NOPOWER))
		return

	. = TRUE

	switch(action)
		if("refresh")
			refresh()

		if("view")
			var/newuid = params["view"]
			for(var/obj/machinery/power/supermatter_shard/S in supermatters)
				if(S.UID() == newuid)
					active = S
					break

		if("back")
			active = null

