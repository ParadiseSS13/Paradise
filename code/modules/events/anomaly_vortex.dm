/datum/event/anomaly/anomaly_vortex
	startWhen = 20
	announceWhen = 3
	endWhen = 80

/datum/event/anomaly/anomaly_vortex/announce()
	GLOB.event_announcement.Announce("Anomalia de vortice de alta intensidad detectada en los escaneres de largo alcance. Ubicacion esperada: [impact_area.name]", "Alerta de Anomalia")

/datum/event/anomaly/anomaly_vortex/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/bhole(T.loc)
