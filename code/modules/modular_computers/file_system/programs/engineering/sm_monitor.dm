/datum/computer_file/program/supermatter_monitor
	filename = "smmonitor"
	filedesc = "Supermatter Monitoring"
	ui_header = "smmon_0.gif"
	program_icon_state = "smmon_0"
	extended_desc = "This program connects to specially calibrated supermatter sensors to provide information on the status of supermatter-based engines."
	requires_ntnet = TRUE
	transfer_access = access_construction
	network_destination = "supermatter monitoring system"
	size = 5
	var/last_status = SUPERMATTER_INACTIVE
	var/list/supermatters
	var/obj/machinery/power/supermatter_shard/active		// Currently selected supermatter crystal.


/datum/computer_file/program/supermatter_monitor/process_tick()
	..()
	var/new_status = get_status()
	if(last_status != new_status)
		last_status = new_status
		if(last_status == SUPERMATTER_ERROR)
			last_status = SUPERMATTER_INACTIVE
		ui_header = "smmon_[last_status].gif"
		program_icon_state = "smmon_[last_status]"
		if(istype(computer))
			computer.update_icon()

/datum/computer_file/program/supermatter_monitor/run_program(mob/living/user)
	. = ..(user)
	refresh()

/datum/computer_file/program/supermatter_monitor/kill_program(forced = FALSE)
	active = null
	supermatters = null
	..()

// Refreshes list of active supermatter crystals
/datum/computer_file/program/supermatter_monitor/proc/refresh()
	supermatters = list()
	var/turf/T = get_turf(nano_host())
	if(!T)
		return
	for(var/obj/machinery/power/supermatter_shard/S in SSair.atmos_machinery)
		// Delaminating, not within coverage, not on a tile.
		if(!(is_station_level(S.z) || is_mining_level(S.z)  || atoms_share_level(S, T) || !istype(S.loc, /turf/simulated/)))
			continue
		supermatters.Add(S)

	if(!(active in supermatters))
		active = null

/datum/computer_file/program/supermatter_monitor/proc/get_status()
	. = SUPERMATTER_INACTIVE
	for(var/obj/machinery/power/supermatter_shard/S in supermatters)
		. = max(., S.get_status())

/datum/computer_file/program/supermatter_monitor/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/headers)
		assets.send(user)
		ui = new(user, src, ui_key, "supermatter_monitor.tmpl", "Supermatter Monitoring", 600, 400)
		ui.set_auto_update(TRUE)
		ui.set_layout_key("program")
		ui.open()

/datum/computer_file/program/supermatter_monitor/ui_data()
	var/list/data = get_header_data()

	if(istype(active))
		var/turf/T = get_turf(active)
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
		var/other_moles = 0.0
		for(var/datum/gas/G in air.trace_gases)
			other_moles+=G.moles
		var/TM = air.total_moles()
		if(TM)
			data["SM_gas_O2"] = round(100*air.oxygen/TM,0.01)
			data["SM_gas_CO2"] = round(100*air.carbon_dioxide/TM,0.01)
			data["SM_gas_N2"] = round(100*air.nitrogen/TM,0.01)
			data["SM_gas_PL"] = round(100*air.toxins/TM,0.01)
			if(other_moles)
				data["SM_gas_OTHER"] = round(100*other_moles/TM,0.01)
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
		for(var/obj/machinery/power/supermatter_shard/S in supermatters)
			var/area/A = get_area(S)
			if(!A)
				continue

			SMS.Add(list(list(
			"area_name" = A.name,
			"integrity" = S.get_integrity(),
			"uid" = S.uid
			)))

		data["active"] = FALSE
		data["supermatters"] = SMS

	return data


/datum/computer_file/program/supermatter_monitor/Topic(href, href_list)
	if(..())
		return TRUE
	if(href_list["clear"])
		active = null
		return TRUE
	if(href_list["refresh"])
		refresh()
		return TRUE
	if(href_list["set"])
		var/newuid = text2num(href_list["set"])
		for(var/obj/machinery/power/supermatter_shard/S in supermatters)
			if(S.uid == newuid)
				active = S
		return TRUE
