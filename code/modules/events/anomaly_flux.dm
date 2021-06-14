/datum/event/anomaly/anomaly_flux
	name = "Anomaly: Hyper-Energetic Flux"
	startWhen = 10
	announceWhen = 3
	anomaly_path = /obj/effect/anomaly/flux

/datum/event/anomaly/anomaly_flux/announce()
	GLOB.event_announcement.Announce("Localized hyper-energetic flux wave detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")
