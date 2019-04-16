/datum/event/anomaly/anomaly_pyro
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/pyro

/datum/event/anomaly/anomaly_pyro/announce(fake)
	event_announcement.Announce("Atmospheric anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")