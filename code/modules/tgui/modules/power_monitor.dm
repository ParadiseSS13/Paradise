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

/datum/ui_module/power_monitor/ui_state(mob/user)
	return GLOB.default_state

/datum/ui_module/power_monitor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PowerMonitor", name)
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
			data["poweravail"] = DisplayPower(powermonitor.powernet.smoothed_available_power)
			data["powerdemand"] = DisplayPower(powermonitor.powernet.smoothed_demand)
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
