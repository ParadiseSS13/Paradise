var/global/datum/repository/apc/apc_repository = new()

/datum/repository/apc/proc/apc_data(datum/powernet/powernet)
	var/apcData[0]

	var/datum/cache_entry/cache_entry = cache_data
	if(!cache_entry)
		cache_entry = new/datum/cache_entry
		cache_data = cache_entry

	if(world.time < cache_entry.timestamp)
		return cache_entry.data

	if(powernet)
		var/list/L = list()
		for(var/obj/machinery/power/terminal/term in powernet.nodes)
			if(istype(term.master, /obj/machinery/power/apc))
				var/obj/machinery/power/apc/A = term.master
				L += A

		var/list/Status = list("Off","AOff","On","AOn") // Status:  off, auto-off, on, auto-on
		var/list/chg = list("N","C","F") // Charging: no, charging, full
		for(var/obj/machinery/power/apc/A in L)
			apcData[++apcData.len] = list("Name" = html_encode(A.area.name), "Equipment" = Status[A.equipment+1], "Lights" = Status[A.lighting+1], "Environment" = Status[A.environ+1], "CellPct" = A.cell ? round(A.cell.percent(),1) : "M", "CellStatus" = A.cell ? chg[A.charging+1] : "M", "Load" = round(A.lastused_total,1))

	cache_entry.timestamp = world.time + 5 SECONDS
	cache_entry.data = apcData
	return apcData