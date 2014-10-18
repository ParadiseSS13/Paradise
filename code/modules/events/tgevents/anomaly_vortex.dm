

/datum/event/anomaly/anomaly_vortex
	startWhen = 20
	announceWhen = 3
	endWhen = 80


/datum/event/anomaly/anomaly_vortex/announce()
	command_alert("Localized high-intensity vortex anomaly detected on long range scanners. Expected location: [impact_area.name]", "Anomaly Alert")

/datum/event/anomaly/anomaly_vortex/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/bhole(T.loc)