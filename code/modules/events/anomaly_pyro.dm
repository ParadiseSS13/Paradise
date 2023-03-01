/datum/event/anomaly/anomaly_pyro
	name = "Anomaly: Pyroclastic"
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/pyro

/datum/event/anomaly/anomaly_pyro/announce()
	GLOB.event_announcement.Announce("На сканерах дальнего действия обнаружена атмосферная аномалия. Предполагаемая локация: [impact_area.name].", "ВНИМАНИЕ: ОБНАРУЖЕНА АНОМАЛИЯ.")
