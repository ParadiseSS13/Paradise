/datum/event/anomaly
	name = "Anomaly: Energetic Flux"
	var/obj/effect/anomaly/anomaly_path = /obj/effect/anomaly/flux
	announceWhen = 1

/datum/event/anomaly/setup()
	impact_area = findEventArea()
	if(!impact_area)
		CRASH("No valid areas for anomaly found.")
	var/list/turf_test = get_area_turfs(impact_area)
	if(!length(turf_test))
		CRASH("Anomaly: No valid turfs found for [impact_area] - [impact_area.type]")

/datum/event/anomaly/announce()
	GLOB.event_announcement.Announce("Localized hyper-energetic flux wave detected on long range scanners. Expected location of impact: [impact_area.name].", "Anomaly Alert", 'sound/AI/anomaly_flux.ogg')

/datum/event/anomaly/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	var/newAnomaly
	if(T)
		newAnomaly = new anomaly_path(T)
	if(newAnomaly)
		announce_to_ghosts(newAnomaly)
