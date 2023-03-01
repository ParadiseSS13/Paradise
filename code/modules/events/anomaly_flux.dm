/datum/event/anomaly/anomaly_flux
	name = "Anomaly: Hyper-Energetic Flux"
	startWhen = 10
	announceWhen = 3
	anomaly_path = /obj/effect/anomaly/flux

/datum/event/anomaly/anomaly_flux/announce()
	GLOB.event_announcement.Announce("На сканерах дальнего действия обнаружена поточная гиперэнергетическая аномалия. Предполагаемая локация: [impact_area.name].", "ВНИМАНИЕ: ОБНАРУЖЕНА АНОМАЛИЯ.")
