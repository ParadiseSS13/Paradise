GLOBAL_DATUM_INIT(powermonitor_repository, /datum/repository/powermonitor, new())

/datum/repository/powermonitor/New()
	cache_data = new/datum/cache_entry

/datum/repository/powermonitor/proc/get_data(z)
	var/datum/cache_entry/cache_entry = cache_data

	return cache_entry.data["[z]"]

/datum/repository/powermonitor/proc/add_to_cache(obj/machinery/computer/monitor/pMon)
	var/datum/cache_entry/cache_entry = cache_data

	LAZYSET(cache_entry.data["[pMon.z]"], "[pMon.UID()]", get_area_name(pMon))

	cache_entry.timestamp = world.time //+ 30 SECONDS

/datum/repository/powermonitor/proc/remove_from_cache(obj/machinery/computer/monitor/pMon)
	var/datum/cache_entry/cache_entry = cache_data
	var/list/pMons_by_z_level = cache_entry.data

	LAZYREMOVEASSOC(pMons_by_z_level, "[pMon.z]", "[pMon.UID()]")

	cache_entry.timestamp = world.time //+ 30 SECONDS
