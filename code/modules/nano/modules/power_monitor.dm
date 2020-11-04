/datum/nano_module/power_monitor
	name = "Power monitor"
	var/select_monitor = 0
	var/obj/machinery/computer/monitor/powermonitor

/datum/nano_module/power_monitor/silicon
	select_monitor = 1

/datum/nano_module/power_monitor/New()
	..()
	if(!select_monitor)
		powermonitor = nano_host()

/datum/nano_module/power_monitor/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = GLOB.default_state)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "power_monitor.tmpl", "Power Monitoring Console", 800, 700, state = state)
		ui.open()
		ui.set_auto_update(1)

/datum/nano_module/power_monitor/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]

	data["powermonitor"] = powermonitor
	if(select_monitor)
		data["select_monitor"] = 1
		data["powermonitors"] = GLOB.powermonitor_repository.powermonitor_data()

	if(powermonitor && !isnull(powermonitor.powernet))
		if(select_monitor && (powermonitor.stat & (NOPOWER|BROKEN)))
			powermonitor = null
			return
		data["poweravail"] = powermonitor.powernet.avail
		data["powerload"] = powermonitor.powernet.viewload
		data["powerdemand"] = powermonitor.powernet.load
		data["apcs"] = GLOB.apc_repository.apc_data(powermonitor.powernet)

	return data

/datum/nano_module/power_monitor/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["selectmonitor"])
		if(issilicon(usr))
			powermonitor = locate(href_list["selectmonitor"])
			powermonitor.powernet = powermonitor.find_powernet() // Refresh the powernet of the monitor
		return 1

	if(href_list["return"])
		if(issilicon(usr))
			powermonitor = null
		return 1
