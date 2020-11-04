/datum/computer_file/program/power_monitor
	filename = "powermonitor"
	filedesc = "Power Monitoring"
	program_icon_state = "power_monitor"
	extended_desc = "This program connects to sensors around the station to provide information about electrical systems"
	ui_header = "power_norm.gif"
	transfer_access = ACCESS_ENGINE
	usage_flags = PROGRAM_CONSOLE
	requires_ntnet = 0
	network_destination = "power monitoring system"
	size = 9
	var/obj/structure/cable/attached

/datum/computer_file/program/power_monitor/run_program(mob/living/user)
	. = ..(user)
	search()

/datum/computer_file/program/power_monitor/process_tick()
	if(!attached)
		search()

/datum/computer_file/program/power_monitor/proc/search()
	var/turf/T = get_turf(computer)
	attached = locate() in T

/datum/computer_file/program/power_monitor/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/headers)
		assets.send(user)
		ui = new(user, src, ui_key, "power_monitor.tmpl", "Alarm Monitoring", 800, 700)
		ui.set_auto_update(1)
		ui.set_layout_key("program")
		ui.open()

/datum/computer_file/program/power_monitor/ui_data()
	var/list/data = get_header_data()

	data["powermonitor"] = attached ? TRUE : FALSE

	if(attached)
		var/datum/powernet/powernet = attached.powernet
		data["poweravail"] = powernet.avail
		data["powerload"] = powernet.viewload
		data["powerdemand"] = powernet.load
		data["apcs"] = GLOB.apc_repository.apc_data(powernet)

	return data
