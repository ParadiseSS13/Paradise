/datum/event/anomaly/anomaly_grav
	name = "Anomaly: Gravitational"
	startWhen = 3
	announceWhen = 20
	anomaly_path = /obj/effect/anomaly/grav

/datum/event/anomaly/anomaly_grav/announce()
	GLOB.event_announcement.Announce("На сканерах дальнего действия обнаружена гравитационная аномалия. Предполагаемая локация: [impact_area.name].", "ВНИМАНИЕ: ОБНАРУЖЕНА АНОМАЛИЯ.")
