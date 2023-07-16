


/client/proc/powernet_debugger()
	set name = "Powernet Debugger"
	set category = "Debug"
	set desc = "Debug our janky ass powernet systems"

	if(!check_rights(R_DEBUG))
		return

	var/datum/ui_module/powernet_debugger/P = new()
	P.ui_interact(usr)

#define PW_DEBUG_SCREEN_POWERNETS	1
#define PW_DEBUG_SCREEN_DETAILS		2

#define PW_MIN_CABLE_COUNT			15

/datum/ui_module/powernet_debugger
	name = "Powernet Debugger"
	///Where we will store our cachedbook datums
	var/datum/regional_powernet/selected_net = null
	var/list/selected_powernets = list()

	var/debug_screen = PW_DEBUG_SCREEN_POWERNETS

	var/list/power_icon_cache = list()



/datum/ui_module/powernet_debugger/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "PowernetDebugger", name, 1000, 600, master_ui, state)
		ui.autoupdate = TRUE
		ui.open()

/datum/ui_module/powernet_debugger/ui_data(mob/user)
	var/list/data = list()
	data["debug_page"] = debug_screen
	data["selected_nets"] = selected_powernets
	data["powernets"] = list()
	for(var/datum/regional_powernet/powernet in SSmachines.powernets)
		if(length(powernet.cables) < PW_MIN_CABLE_COUNT)
			continue // we don't give a shit about tiny powernets
		var/obj/structure/cable/test_cable = powernet.cables[1]
		if(!is_station_level(test_cable.z))
			continue // we don't give a shit about powernets off the station z-level
		var/list/powernet_data = list(
			"PW_UID" = powernet.UID(),
			"voltage" = powernet.power_voltage_type,
			"cables" = length(powernet.cables),
			"nodes" = length(powernet.nodes),
			"batteries" = length(powernet.batteries),
			"subnet_connectors" = length(powernet.subnet_connectors),
			"available_power" = powernet.available_power,
			"power_demand" = powernet.power_demand,
			"queued_demand" = powernet.queued_power_demand,
			"queued_production" = powernet.queued_power_production
		)
		data["powernets"] += list(powernet_data)
	data["selected_net"] = list()
	if(!isnull(selected_net))
		var/list/powernet_data = list(
			"PW_UID" = selected_net.UID(),
			"voltage" = selected_net.power_voltage_type,
			"cables" = length(selected_net.cables),
			"nodes" = length(selected_net.nodes),
			"batteries" = length(selected_net.batteries),
			"subnet_connectors" = length(selected_net.subnet_connectors),
			"available_power" = selected_net.available_power,
			"power_demand" = selected_net.power_demand,
			"queued_demand" = selected_net.queued_power_demand,
			"queued_production" = selected_net.queued_power_production
		)
		data["selected_net"]["stats"] = powernet_data
		data["selected_net"]["batteries"] = list()
		for(var/obj/machinery/power/battery/battery in selected_net.batteries)
			var/obj/machinery/power/battery/accumulator/accumulator = battery
			var/list/battery_data = list(
				"PW_UID" = battery.UID(),
				"name" = battery.name,
				"type" = battery.type,
				"dir" = dir2text(battery.dir),
				"status" = battery.battery_status,
				"charge" = battery.charge,
				"max_charge" = battery.max_capacity,
				"safe_capacity" = istype(accumulator) ? accumulator.safe_capacity : "N/A"
			)
			data["selected_net"]["batteries"] += list(battery_data)
		data["selected_net"]["transformers"] = list()
		for(var/obj/machinery/power/transformer/transformer in selected_net.subnet_connectors)
			var/list/transformer_data = list(
				"PW_UID" = transformer.UID(),
				"name" = transformer.name,
				"type" = transformer.type,
				"dir" = dir2text(transformer.dir),
				"wattage_setting" = transformer.wattage_setting,
				"last_output" = transformer.last_output
			)
			get_power_icon(transformer, transformer.dir)
			data["selected_net"]["transformers"] += list(transformer_data)
		data["selected_net"]["power_machines"] = list()
		var/list/power_machines = selected_net.nodes
		for(var/obj/machinery/power/terminal/terminal in selected_net.nodes)
			power_machines |= terminal.master
		for(var/obj/machinery/power/power_machine in power_machines)
			var/list/transformer_data = list(
				"PW_UID" = power_machine.UID(),
				"name" = power_machine.name,
				"type" = power_machine.type,
				"dir" = dir2text(power_machine.dir),
			)
			data["selected_net"]["power_machines"] += list(transformer_data)
			get_power_icon(power_machine, power_machine.dir)
		data["power_images"] = power_icon_cache
	else if(debug_screen == PW_DEBUG_SCREEN_DETAILS)
		debug_screen = PW_DEBUG_SCREEN_POWERNETS // powernets can be remade at a moments notice, kick them out of the menu
	return data

/datum/ui_module/powernet_debugger/proc/get_power_icon(obj/power_machine, machine_dir)
	if(!machine_dir)
		machine_dir = SOUTH
	if(!power_icon_cache[power_machine.type])
		power_icon_cache[power_machine.type] = list()
	if(!power_icon_cache[power_machine.type][dir2text(machine_dir)])
		power_icon_cache[power_machine.type][dir2text(machine_dir)] = "[icon2base64(icon(power_machine.icon, power_machine.icon_state, machine_dir))]"
	return power_icon_cache[power_machine.type][dir2text(machine_dir)]

/datum/ui_module/powernet_debugger/ui_act(action, params, datum/tgui/ui)
	if(!check_rights(R_DEBUG))
		return
	if(..())
		return

	switch(action)
		if("detailed_view")
			var/datum/regional_powernet/powernet = locateUID(params["PW_UID"])
			if(!istype(powernet))
				return
			selected_powernets |= params["PW_UID"]
			selected_net = powernet
			debug_screen = PW_DEBUG_SCREEN_DETAILS
		if("jmp")
			var/client/C = ui.user.client
			var/obj/machinery/power/power_machine = locateUID(params["PW_UID"])
			if(!istype(power_machine))
				return
			sleep(2)
			C.jumptocoord(power_machine.x, power_machine.y, power_machine.z)
		if("set_page")
			var/new_page = text2num(params["page"])
			if(!new_page)
				return
			debug_screen = new_page
		if("clear_tabs")
			debug_screen = PW_DEBUG_SCREEN_POWERNETS
			selected_powernets = list()
			selected_net = null
