#define TURF_FIND_TRIES 10

/datum/event/anomaly
	name = "Anomaly: Energetic Flux"
	var/obj/effect/anomaly/anomaly_path = /obj/effect/anomaly/flux
	var/turf/target_turf
	announceWhen = 1

/datum/event/anomaly/setup()
	for(var/tries in 0 to TURF_FIND_TRIES)
		impact_area = findEventArea()
		if(!impact_area)
			CRASH("No valid areas for anomaly found.")
		var/list/candidate_turfs = get_area_turfs(impact_area)
		while(length(candidate_turfs))
			var/turf/candidate = pick_n_take(candidate_turfs)
			if(!is_blocked_turf(candidate,TRUE))
				target_turf = candidate
				break
		if(target_turf)
			break
	if(!target_turf)
		CRASH("Anomaly: Unable to find a valid turf to spawn the anomaly. Last area tried: [impact_area] - [impact_area.type]")

/datum/event/anomaly/announce()
	GLOB.minor_announcement.Announce("Localized hyper-energetic flux wave detected on long range scanners. Expected location of impact: [impact_area.name].", "Anomaly Alert", 'sound/AI/anomaly_flux.ogg')

/datum/event/anomaly/start()
	var/newAnomaly = new anomaly_path(target_turf)
	announce_to_ghosts(newAnomaly)

#undef TURF_FIND_TRIES
