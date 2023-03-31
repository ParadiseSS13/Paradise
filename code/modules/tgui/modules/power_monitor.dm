/datum/ui_module/power_monitor
	name = "Power monitor"
	var/select_monitor = FALSE
	var/obj/machinery/computer/monitor/powermonitor

/datum/ui_module/power_monitor/digital
	select_monitor = TRUE

/datum/ui_module/power_monitor/New()
	..()
	if(!select_monitor)
		powermonitor = ui_host()

/datum/ui_module/power_monitor/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "PowerMonitor", name, 600, 650, master_ui, state)
		ui.open()

/datum/ui_module/power_monitor/ui_data(mob/user)
	var/list/data = list()

	// Sanity check
	if(QDELETED(powermonitor))
		powermonitor = null

	data["powermonitor"] = powermonitor
	if(select_monitor)
		data["select_monitor"] = TRUE
		data["powermonitors"] = GLOB.powermonitor_repository.powermonitor_data()

	if(powermonitor)
		if(select_monitor && (powermonitor.stat & (NOPOWER|BROKEN)))
			powermonitor = null
			return
		if(powermonitor.powernet)
			data["poweravail"] = DisplayPower(powermonitor.powernet.viewavail)
			data["powerdemand"] = DisplayPower(powermonitor.powernet.viewload)
			data["history"] = powermonitor.history
			data["apcs"] = GLOB.apc_repository.apc_data(powermonitor.powernet)
			data["no_powernet"] = FALSE
		else
			data["no_powernet"] = TRUE

	return data

/datum/ui_module/power_monitor/ui_act(action, list/params)
	if(..())
		return

	// Dont allow people to break regular ones
	if(!select_monitor)
		return

	. = TRUE
	switch(action)
		if("selectmonitor")
			powermonitor = locateUID(params["selectmonitor"])
			powermonitor.powernet = powermonitor.find_powernet() // Refresh the powernet of the monitor

		if("return")
			powermonitor = null
