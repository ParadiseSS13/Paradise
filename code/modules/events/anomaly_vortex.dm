/datum/event/anomaly/anomaly_vortex
	name = "Anomaly: Vortex"
	startWhen = 10
	announceWhen = 3
	anomaly_path = /obj/effect/anomaly/bhole

/datum/event/anomaly/anomaly_vortex/announce()
	GLOB.event_announcement.Announce("Localized high-intensity vortex anomaly detected on long range scanners. Expected location: [impact_area.name]", "Anomaly Alert")
