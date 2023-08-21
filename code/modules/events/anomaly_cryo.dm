/datum/event/anomaly/anomaly_cryo
	name = "Anomaly: Cryogenic"
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/cryo

/datum/event/anomaly/anomaly_cryo/announce()
	GLOB.minor_announcement.Announce("Cryogenic anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", 'sound/AI/anomaly_pyro.ogg')
