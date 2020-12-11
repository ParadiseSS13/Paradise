/datum/event/anomaly/anomaly_flux
	startWhen = 3
	announceWhen = 20
	endWhen = 180

/datum/event/anomaly/anomaly_flux/announce()
	GLOB.event_announcement.Announce("Localized hyper-energetic flux wave detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")

/datum/event/anomaly/anomaly_flux/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/flux(T.loc)

/datum/event/anomaly/anomaly_flux/end()
	if(newAnomaly.loc)//If it hasn't been neutralized, it's time to blow up.
		explosion(newAnomaly, -1, 3, 5, 5)
		qdel(newAnomaly)
