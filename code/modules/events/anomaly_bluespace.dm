/datum/event/anomaly/anomaly_bluespace
	name = "Anomaly: Bluespace"
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/bluespace

/datum/event/anomaly/anomaly_bluespace/announce()
	GLOB.event_announcement.Announce("Unstable bluespace anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")
