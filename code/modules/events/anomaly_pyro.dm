/datum/event/anomaly/anomaly_pyro
	name = "Anomaly: Pyroclastic"
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/pyro

/datum/event/anomaly/anomaly_pyro/announce()
	GLOB.minor_announcement.Announce("Pyroclastic anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", 'sound/AI/anomaly_pyro.ogg')
