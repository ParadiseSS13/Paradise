/datum/event/anomaly
	var/obj/effect/anomaly/newAnomaly
	announceWhen = 1

/datum/event/anomaly/setup(loop=0)
	var/safety_loop = loop + 1
	if(safety_loop > 50)
		kill()
		end()
	impact_area = findEventArea()
	if(!impact_area)
		setup(safety_loop)
	var/list/turf_test = get_area_turfs(impact_area)
	if(!turf_test.len)
		setup(safety_loop)

/datum/event/anomaly/announce()
	event_announcement.Announce("Localized hyper-energetic flux wave detected on long range scanners. Expected location of impact: [impact_area.name].", "Anomaly Alert")

/datum/event/anomaly/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/flux(T.loc)

/datum/event/anomaly/tick()
	if(!newAnomaly)
		kill()
		return
	newAnomaly.anomalyEffect()

/datum/event/anomaly/end()
	if(newAnomaly)//Kill the anomaly if it still exists at the end.
		qdel(newAnomaly)