/datum/event/anomaly/anomaly_vortex
	name = "Anomaly: Vortex"
	startWhen = 10
	announceWhen = 3
	anomaly_path = /obj/effect/anomaly/bhole

/datum/event/anomaly/anomaly_vortex/announce()
	GLOB.event_announcement.Announce("На сканерах дальнего действия обнаружена вихревая аномалия высокой интенсивности. Предполагаемая локация: [impact_area.name]", "ВНИМАНИЕ: ОБНАРУЖЕНА АНОМАЛИЯ.")
