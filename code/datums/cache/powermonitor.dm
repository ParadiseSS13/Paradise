GLOBAL_DATUM_INIT(powermonitor_repository, /datum/repository/powermonitor, new())

/datum/repository/powermonitor/proc/powermonitor_data(refresh = 0)
	var/pMonData[0]

	var/datum/cache_entry/cache_entry = cache_data
	if(!cache_entry)
		cache_entry = new/datum/cache_entry
		cache_data = cache_entry

	if(!refresh)
		return cache_entry.data

	for(var/obj/machinery/computer/monitor/pMon in GLOB.power_monitors)
		if(!(pMon.stat & (NOPOWER|BROKEN)) && !pMon.is_secret_monitor)
			pMonData[++pMonData.len] = list ("Area" = get_area_name(pMon), "uid" = "[pMon.UID()]")

	cache_entry.timestamp = world.time //+ 30 SECONDS
	cache_entry.data = pMonData
	return pMonData

/datum/repository/powermonitor/proc/update_cache()
	return powermonitor_data(refresh = 1)

