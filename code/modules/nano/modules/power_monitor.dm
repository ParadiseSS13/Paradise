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
	
/datum/nano_module/power_monitor/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = default_state)
	var/data[0]
	var/pMonData[0]
	var/apcData[0]
		
	data["powermonitor"] = powermonitor
	if(select_monitor)
		data["select_monitor"] = 1
		for(var/obj/machinery/computer/monitor/pMon in world)
			if( !(pMon.stat & (NOPOWER|BROKEN)) )
				pMonData[++pMonData.len] = list ("Name" = pMon.name, "ref" = "\ref[pMon]")
		
		data["powermonitors"] = pMonData

	if (powermonitor && !isnull(powermonitor.powernet))
		data["poweravail"] = powermonitor.powernet.avail
		data["powerload"] = num2text(powermonitor.powernet.viewload,10)
		var/list/L = list()
		for(var/obj/machinery/power/terminal/term in powermonitor.powernet.nodes)
			if(istype(term.master, /obj/machinery/power/apc))
				var/obj/machinery/power/apc/A = term.master
				L += A

		var/list/Status = list(0,0,1,1) // Status:  off, auto-off, on, auto-on
		var/list/chg = list(0,1,1)	// Charging: nope, charging, full
		for(var/obj/machinery/power/apc/A in L)
			apcData[++apcData.len] = list("Name" = html_encode(A.area.name), "Equipment" = Status[A.equipment+1], "Lights" = Status[A.lighting+1], "Environment" = Status[A.environ+1], "CellPct" = A.cell ? round(A.cell.percent(),1) : -1, "CellStatus" = A.cell ? chg[A.charging+1] : 0)

		data["apcs"] = apcData

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "power_monitor.tmpl", "Power Monitoring Console", 800, 700, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
		
/datum/nano_module/power_monitor/Topic(href, href_list)
	if(..()) 
		return 1

	if(href_list["selectmonitor"])
		if(issilicon(usr))
			powermonitor = locate(href_list["selectmonitor"])
		return 1
		
	if(href_list["return"])
		if(issilicon(usr))
			powermonitor = null
		return 1
		