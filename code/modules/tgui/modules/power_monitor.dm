/datum/tgui_module/power_monitor
	name = "Power monitor"
	var/select_monitor = FALSE
	var/obj/machinery/computer/monitor/powermonitor

/datum/tgui_module/power_monitor/digital
	select_monitor = TRUE

/datum/tgui_module/power_monitor/New()
	..()
	if(!select_monitor)
		powermonitor = tgui_host()

/datum/tgui_module/power_monitor/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "PowerMonitor", name, 600, 650, master_ui, state)
		ui.open()

/datum/tgui_module/power_monitor/tgui_data(mob/user)
	var/list/data = list()

	data["powermonitor"] = powermonitor
	if(select_monitor)
		data["select_monitor"] = TRUE
		data["powermonitors"] = GLOB.powermonitor_repository.powermonitor_data()

	if(powermonitor && !isnull(powermonitor.powernet))
		if(select_monitor && (powermonitor.stat & (NOPOWER|BROKEN)))
			powermonitor = null
			return
		data["poweravail"] = DisplayPower(powermonitor.powernet.viewavail)
		data["powerdemand"] = DisplayPower(powermonitor.powernet.viewload)
		data["history"] = powermonitor.history
		data["apcs"] = GLOB.apc_repository.apc_data(powermonitor.powernet)

	return data

/datum/tgui_module/power_monitor/tgui_act(action, list/params)
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
