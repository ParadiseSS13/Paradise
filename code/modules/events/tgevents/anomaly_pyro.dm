

/datum/event/anomaly/anomaly_pyro
	startWhen = 30
	announceWhen = 3
	endWhen = 110


/datum/event/anomaly/anomaly_pyro/announce()
	command_alert("Atmospheric anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")

/datum/event/anomaly/anomaly_pyro/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/pyro(T.loc)

/datum/event/anomaly/anomaly_pyro/tick()
	if(!newAnomaly)
		kill()
		return
	if(IsMultiple(activeFor, 5))
		newAnomaly.anomalyEffect()