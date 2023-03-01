/datum/event/anomaly/anomaly_bluespace
	name = "Anomaly: Bluespace"
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/bluespace

/datum/event/anomaly/anomaly_bluespace/announce()
	GLOB.event_announcement.Announce("На сканерах дальнего действия обнаружена нестабильная блюспейс-аномалия. Предполагаемая локация: [impact_area.name].", "ВНИМАНИЕ: ОБНАРУЖЕНА АНОМАЛИЯ.")
