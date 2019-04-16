/datum/event/anomaly/anomaly_grav
	startWhen = 3
	announceWhen = 20
	anomaly_path = /obj/effect/anomaly/grav

/datum/event/anomaly/anomaly_grav/announce(fake)
	event_announcement.Announce("Gravitational anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")