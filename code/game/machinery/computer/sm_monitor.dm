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
	var/obj/machinery/atmospherics/supermatter_crystal/active

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

/obj/machinery/computer/sm_monitor/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/sm_monitor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SupermatterMonitor", name)
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
		var/datum/gas_mixture/air = T.get_readonly_air()
		if(!air)
			active = null
			return

		data["active"] = TRUE
		data["SM_integrity"] = active.get_integrity()
		data["SM_power"] = active.power
		data["SM_pre_reduction_power"] = active.pre_reduction_power
		data["SM_ambienttemp"] = air.temperature()
		data["SM_ambientpressure"] = air.return_pressure()
		data["SM_moles"] = air.total_moles()
		data["SM_gas_coefficient"] = active.gas_coefficient
		//data["SM_EPR"] = round((air.total_moles / air.group_multiplier) / 23.1, 0.01)
		var/list/gasdata = list()
		var/TM = air.total_moles()
		if(TM)
			gasdata.Add(list(list("name"= "Oxygen", "amount" = air.oxygen(), "portion" = round(100 * air.oxygen() / TM, 0.01))))
			gasdata.Add(list(list("name"= "Carbon Dioxide", "amount" = air.carbon_dioxide(), "portion" = round(100 * air.carbon_dioxide() / TM, 0.01))))
			gasdata.Add(list(list("name"= "Nitrogen", "amount" = air.nitrogen(), "portion" = round(100 * air.nitrogen() / TM, 0.01))))
			gasdata.Add(list(list("name"= "Plasma", "amount" = air.toxins(), "portion" = round(100 * air.toxins() / TM, 0.01))))
			gasdata.Add(list(list("name"= "Nitrous Oxide", "amount" = air.sleeping_agent(), "portion" = round(100 * air.sleeping_agent() / TM, 0.01))))
			gasdata.Add(list(list("name"= "Agent B", "amount" = air.agent_b(), "portion" = round(100 * air.agent_b() / TM, 0.01))))
		else
			gasdata.Add(list(list("name"= "Oxygen", "amount" = 0, "portion" = 0)))
			gasdata.Add(list(list("name"= "Carbon Dioxide", "amount" = 0,"portion" = 0)))
			gasdata.Add(list(list("name"= "Nitrogen", "amount" = 0,"portion" = 0)))
			gasdata.Add(list(list("name"= "Plasma", "amount" = 0,"portion" = 0)))
			gasdata.Add(list(list("name"= "Nitrous Oxide", "amount" = 0,"portion" = 0)))
			gasdata.Add(list(list("name"= "Agent B", "amount" = 0,"portion" = 0)))
		data["gases"] = gasdata
	else
		var/list/SMS = list()
		for(var/I in supermatters)
			var/obj/machinery/atmospherics/supermatter_crystal/S = I
			var/area/A = get_area(S)
			if(!A)
				continue

			SMS.Add(list(list(
				"area_name" = A.name,
				"integrity" = S.get_integrity(),
				"supermatter_id" = S.supermatter_id
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
	for(var/obj/machinery/atmospherics/supermatter_crystal/S in SSair.atmos_machinery)
		// Delaminating, not within coverage, not on a tile.
		if(!atoms_share_level(S, T) || !issimulatedturf(S.loc))
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
			var/newuid = text2num(params["view"])
			for(var/obj/machinery/atmospherics/supermatter_crystal/S in supermatters)
				if(S.supermatter_id == newuid)
					active = S
					break

		if("back")
			active = null
