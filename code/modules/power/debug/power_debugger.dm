
/client/proc/powernet_debugger()
	set name = "Powernet Debugger"
	set category = "Debug"
	set desc = "Get Debug Information about Local/Regional Powernets in the World"

	if(!check_rights(R_DEBUG))
		return

	var/datum/ui_module/powernet_debugger/P = new()
	P.ui_interact(usr)

/// Screen define, makes the TGUI for the powernet debugger display the list of regional powernets in the world
#define PW_DEBUG_SCREEN_POWERNETS	1
/// Screen define, makes the TGUI for the powernet debugger display detailed information about a specified Regional/Local Net
#define PW_DEBUG_SCREEN_DETAILS		2
/// Sets the minimum cable count for a regional powernet to be displayed on the Debugger, declogs the menu so that only relevant nets are included
#define PW_MIN_CABLE_COUNT			5

/*
	* The Powernet Debugger
	*
	* Got a problem with powernets? This UI module will give you all the information (+ visuals) you could ever want to know and more!
	* Beyond dumping a list of regional powernets for you to overview, you can click on them to get details about the machines
	* contained, local powernets, and general state
	*
	* This tool is also great for looking at local powernets and investigating where power is being consumed and the various states
	* that `/machinery` is in. Furthermore, as a contributor, you can add additional functionality through powernet logging that's
	* automatically built into local powernets and this tool, on production it does nothing but if you're trying to investigate something
	* specific, you can track whatever you want on a local net and view it through this UI module.

*/
/datum/ui_module/powernet_debugger
	name = "Powernet Debugger"
	/// A hard reference to the currnet regional powernet we are analyzing in the UI screen
	var/datum/regional_powernet/selected_regional_net = null
	/// A hard reference to the current local powernet we are analyzing in the UI screen
	var/datum/local_powernet/selected_local_net = null

	/// a list of UIDs pointing to powernets we have selected, all powernets in this list will show up as tabs in the UI module, great for bouncing between multiple things
	var/list/selected_powernets = list()
	/// The current screen we're on, just used to distinguish looking at the list of regional powernets vs. the detailed view of the net we have selected
	var/debug_screen = PW_DEBUG_SCREEN_POWERNETS
	/// A cache of machines/power-machines that we're listing. We don't want to send a billion icons to the UI-module, so we only send one of each by caching stuff
	var/list/power_icon_cache = list()

	// # Filter Tools
	/// When TRUE, removes pipes from the local powernet machine list
	var/filter_pipes = FALSE
	/// When TRUE, removes walls lights from the local powernet machine list
	var/filter_lights = FALSE
	/// When TRUE, removes APCs from the regional powernet power machine list
	var/filter_apcs = FALSE
	/// When TRUE, removes terminals from the regional powernet power machine list
	var/filter_terminals = FALSE
	/// When TRUE, removes off-station powernets from the initial regional powernet list
	var/filter_non_station_powernets = TRUE // enabled by default b/c most contributors and admins wont care about off-station nets

/datum/ui_module/library_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/ui_module/powernet_debugger/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PowernetDebugger", name)
		ui.autoupdate = TRUE
		ui.open()

/// Returns a list of data on regional powernets in the world to be used in ui_act that
/datum/ui_module/powernet_debugger/proc/get_all_powernets()
	var/list/powernets = list()
	for(var/datum/regional_powernet/powernet in SSmachines.powernets)
		if(length(powernet.cables) < PW_MIN_CABLE_COUNT)
			continue // we don't give a shit about tiny powernets
		var/obj/structure/cable/test_cable = powernet.cables[1]
		if(filter_non_station_powernets && !is_station_level(test_cable.z))
			continue // we don't give a shit about powernets off the station z-level
		var/list/powernet_data = list(
			"PW_UID" = powernet.UID(),
			"cables" = length(powernet.cables),
			"nodes" = length(powernet.nodes),
			"available_power" = powernet.available_power,
			"power_demand" = powernet.power_demand,
			"queued_demand" = powernet.queued_power_demand,
			"queued_production" = powernet.queued_power_production
		)
		powernets += list(powernet_data)
	return powernets

/// Gets ui_data for the selected regional or local net, returns an empty list if nothing is selected
/datum/ui_module/powernet_debugger/proc/get_selected_powernet_data()
	if(!isnull(selected_regional_net))
		return get_regional_net_data(selected_regional_net)
	else if(!isnull(selected_local_net))
		return get_local_net_data(selected_local_net)
	else if(debug_screen == PW_DEBUG_SCREEN_DETAILS)
		debug_screen = PW_DEBUG_SCREEN_POWERNETS // powernets can be remade at a moments notice, kick them out of the menu now!
	return list() //return an empty list

/// Gets ui_data for the selected regional net and returns it
/datum/ui_module/powernet_debugger/proc/get_regional_net_data(datum/regional_powernet/regional_net)
	var/list/powernet_data = list()
	// set the net type so that our UI knows what data to look for
	powernet_data["net_type"] = "regional"
	// basic summary of the net
	powernet_data["power_stats"] = list(
		"PW_UID" = selected_regional_net.UID(),
		"cables" = length(selected_regional_net.cables),
		"nodes" = length(selected_regional_net.nodes),
		"available_power" = selected_regional_net.available_power,
		"power_demand" = selected_regional_net.power_demand,
		"queued_demand" = selected_regional_net.queued_power_demand,
		"queued_production" = selected_regional_net.queued_power_production
	)
	powernet_data["power_machines"] = list()
	// grab all end points of our powernet
	var/list/power_machines = selected_regional_net.nodes
	for(var/obj/machinery/power/terminal/terminal in selected_regional_net.nodes)
		power_machines |= terminal.master // we want to grab all the machines terminals are hooked up to since they're not included in the nodes
	for(var/obj/machinery/power/power_machine in power_machines)
		if(filter_apcs && isapc(power_machine))
			continue
		if(filter_terminals && istype(power_machine, /obj/machinery/power/terminal))
			continue
		var/list/machine_data = list(
			"PW_UID" = power_machine.UID(),
			"name" = power_machine.name,
			"type" = power_machine.type,
			"dir" = dir2text(power_machine.dir),
		)
		powernet_data["power_machines"] += list(machine_data)
		get_power_icon(power_machine, power_machine.dir)
	// since we're a regional net, we want to see all the local nets hooked up to us for further investigation
	powernet_data["local_powernets"] = list()
	for(var/obj/machinery/power/terminal/terminal in selected_regional_net.nodes)
		if(!isapc(terminal.master))
			continue
		var/obj/machinery/power/apc/net_apc = terminal.master
		var/datum/local_powernet/local_net = net_apc.machine_powernet
		var/list/local_powernet_data = list(
			"PW_UID" = local_net.UID(),
			"name" = local_net.powernet_area.name,
			"machines" = length(local_net.registered_machines),
			"master" = net_apc.operating ? "On" : "Off",
			"equipment" = local_net.equipment_powered ? "On" : "Off",
			"lighting" = local_net.lighting_powered ? "On" : "Off",
			"environment" = local_net.environment_powered ? "On" : "Off",
		)
		powernet_data["local_powernets"] += list(local_powernet_data)
	return powernet_data

/// Gets ui_data for the selected local net and returns it
/datum/ui_module/powernet_debugger/proc/get_local_net_data(datum/local_powernet/local_net)
	var/list/powernet_data = list()
	powernet_data["net_type"] = "local"
	// first thing we do is start summarizing info about powernet
	var/power_flag = "No Power Flags"
	if(selected_local_net.power_flags & PW_ALWAYS_UNPOWERED)
		power_flag = "Always Unpowered"
	if(selected_local_net.power_flags & PW_ALWAYS_POWERED)
		power_flag += "Always Powered" // += is included here because we want to know if someone doubled up flags accidently and is causing issues
	// Basic facts about the powernet
	powernet_data["power_stats"] = list(
		"PW_UID" = selected_local_net.UID(),
		"area_name" = selected_local_net.powernet_area.name,
		"power_flag" = power_flag,
		"has_apc" = istype(selected_local_net.powernet_apc),
		"all_channels" = list("powered" = selected_local_net.powernet_apc?.operating, "passive_consumption" = selected_local_net.get_total_usage()),
		"equipment_channel" = list("powered" = selected_local_net.equipment_powered, "passive_consumption" = selected_local_net.get_channel_usage(PW_CHANNEL_EQUIPMENT)),
		"lighting_channel" = list("powered" = selected_local_net.lighting_powered, "passive_consumption" = selected_local_net.get_channel_usage(PW_CHANNEL_LIGHTING)),
		"environment_channel" = list("powered" = selected_local_net.environment_powered, "passive_consumption" = selected_local_net.get_channel_usage(PW_CHANNEL_ENVIRONMENT)),
	)
	powernet_data["local_machines"] = list()
	for(var/obj/machinery/machine in selected_local_net.registered_machines)
		if(filter_lights && istype(machine, /obj/machinery/light))
			continue
		if(filter_pipes && istype(machine, /obj/machinery/atmospherics/pipe))
			continue
		var/list/machine_data = list(
			"PW_UID" = machine.UID(),
			"name" = machine.name,
			"powered" = !(machine.stat & NOPOWER),
			"pw_channel" = local_net.channel_to_name(machine.power_channel), //we love helper procs!
			"pw_state" = local_net.state_to_name(machine.power_state),
			"idle_consumption" = machine.idle_power_consumption,
			"active_consumption" = machine.active_power_consumption,
			"type" = machine.type,
			"dir" = dir2text(machine.dir),
		)
		powernet_data["local_machines"] += list(machine_data)
		get_power_icon(machine, machine.dir)
	powernet_data["logs"] = selected_local_net.powernet_log
	return powernet_data


/datum/ui_module/powernet_debugger/ui_data(mob/user)
	var/list/data = list()

	// # Filter Data
	data["filters"] = list(
		"pipes" = filter_pipes,
		"lights" = filter_lights,
		"apcs" = filter_apcs,
		"terminals" = filter_terminals,
		"off_station" = filter_non_station_powernets
	)

	// Global info
	data["debug_page"] = debug_screen
	// all powernets we have actively selected, this generates the tabs in our UI
	data["selected_nets"] = selected_powernets
	// list of all regional powernets
	data["powernets"] = get_all_powernets()
	// Detailed page info
	data["selected_net"] = get_selected_powernet_data()
	// a copy of our power icon cache, used to generate pictures of power machines for use in our UI's tables
	data["power_images"] = power_icon_cache

	return data

/// Since we need icons for our UI, this proc will generate the icon if and only if the icon for that type in the specified direction does not already
/// have its icon generated. Otherwise it pulls the icon in that dir from the cache. Avoids having to regenerate icons every data update!
/datum/ui_module/powernet_debugger/proc/get_power_icon(obj/power_machine, machine_dir = SOUTH)
	if(!machine_dir) // need a direction or this proc runtimes, default to south if null
		machine_dir = SOUTH
	if(!power_icon_cache[power_machine.type]) // have we cached this type yet?
		power_icon_cache[power_machine.type] = list()
	if(!power_icon_cache[power_machine.type][dir2text(machine_dir)]) // have we cached this type in the specified direction yet?
		power_icon_cache[power_machine.type][dir2text(machine_dir)] = "[icon2base64(icon(power_machine.icon, power_machine.icon_state, machine_dir))]"
	return power_icon_cache[power_machine.type][dir2text(machine_dir)] // return the icon incase we need it!

/datum/ui_module/powernet_debugger/ui_act(action, params, datum/tgui/ui)
	if(!check_rights(R_DEBUG))
		return
	if(..())
		return

	switch(action)
		if("detailed_view")
			var/datum/powernet = locateUID(params["PW_UID"])
			if(istype(powernet, /datum/regional_powernet))
				selected_regional_net = powernet
				selected_local_net = null
			else if(istype(powernet, /datum/local_powernet))
				selected_local_net = powernet
				selected_regional_net = null
			else
				return
			selected_powernets |= params["PW_UID"]
			debug_screen = PW_DEBUG_SCREEN_DETAILS
		if("open_vv")
			var/client/C = ui.user.client
			if(!check_rights(R_ADMIN))
				return
			var/datum/tgt = locateUID(params["tgt_UID"])
			if(!tgt)
				return
			C.debug_variables(tgt)
		if("jmp")
			var/client/C = ui.user.client
			// normally, in TGUI params, we would be more careful about preventing the usr from inject any atoms UID, however non-admins can't use jumptocoord!
			var/atom/AM = locateUID(params["tgt_UID"])
			if(!istype(AM))
				return
			sleep(2)
			if(istype(AM, /datum/local_powernet))
				var/datum/local_powernet/net_to_teleport_to = AM
				C.jumptoarea(net_to_teleport_to.powernet_area)
				return
			if(isobj(AM) && !isnull(AM.loc)) // pretty much anything else you can target with "jmp"
				var/obj/O = AM
				C.jumptocoord(O.x, O.y, O.z)
		if("set_page")
			var/new_page = text2num(params["page"])
			if(!new_page)
				return
			debug_screen = new_page
		if("clear_tabs")
			debug_screen = PW_DEBUG_SCREEN_POWERNETS
			selected_powernets = list()
			selected_regional_net = null
			selected_local_net = null
		// start filter button actions
		if("filter_off_station")
			filter_non_station_powernets = !filter_non_station_powernets
		if("filter_apcs")
			filter_apcs = !filter_apcs
		if("filter_terminals")
			filter_terminals = !filter_terminals
		if("filter_lights")
			filter_lights = !filter_lights
		if("filter_pipes")
			filter_pipes = !filter_pipes

#undef PW_DEBUG_SCREEN_POWERNETS	1
#undef PW_DEBUG_SCREEN_DETAILS		2
#undef PW_MIN_CABLE_COUNT			5

//
//		  "Death to Powernet Bugs"
//
//	          .--.         .--.
//	              \       /
//	       |\      `\___/'       /|
//	        \\    .-'@ @`-.     //
//	        ||  .'_________`.  ||
//	         \\.'^    Y    ^`.//
//	         .'       |       `.
//	        :         |         :
//	       :          |          :
//	       :          |          :
//	       :     _    |    _     :
//	       :.   (_)   |   (_)    :
//	     __::.        |          :__
//	    /.--::.       |         :--.|
//	 __//'   `::.     |       .'   `\\___
//	`--'     //`::.   |     .'\\     `--'
//	         ||  `-.__|__.-'   ||
//	         ||                ||
//	         //                \\
//	        |/                  \|
//
