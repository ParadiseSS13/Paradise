var/global/datum/repository/powermonitor/powermonitor_repository = new()

/datum/repository/powermonitor/proc/powermonitor_data(var/refresh = 0)
	var/pMonData[0]
	
	var/datum/cache_entry/cache_entry = cache_data
	if(!cache_entry)
		cache_entry = new/datum/cache_entry
		cache_data = cache_entry

	if(!refresh)
		return cache_entry.data
	
	for(var/obj/machinery/computer/monitor/pMon in GLOB.power_monitors)
		if( !(pMon.stat & (NOPOWER|BROKEN)) )
			pMonData[++pMonData.len] = list ("Name" = pMon.name, "ref" = "\ref[pMon]")

	cache_entry.timestamp = world.time //+ 30 SECONDS
	cache_entry.data = pMonData				
	return pMonData
	
/datum/repository/powermonitor/proc/update_cache()
	return powermonitor_data(refresh = 1)
	