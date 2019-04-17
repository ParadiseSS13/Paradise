/datum/event/anomaly
	var/obj/effect/anomaly/anomaly_path = /obj/effect/anomaly/flux
	announceWhen	= 1

/datum/event/anomaly/setup()
	impact_area = findEventArea()
	if(!impact_area)
		CRASH("No valid areas for anomaly found.")
	var/list/turf_test = get_area_turfs(impact_area)
	if(!turf_test.len)
		CRASH("Anomaly : No valid turfs found for [impact_area] - [impact_area.type]")

/datum/event/anomaly/announce(fake)
	event_announcement.Announce("Localized hyper-energetic flux wave detected on long range scanners. Expected location of impact: [impact_area.name].", "Anomaly Alert")

/datum/event/anomaly/start()
	var/turf/T = safepick(get_area_turfs(impact_area))
	if(T)
		new anomaly_path(T)