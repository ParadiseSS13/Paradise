/datum/event/anomaly/anomaly_grav
	startWhen = 3
	announceWhen = 20
	endWhen = 70

/datum/event/anomaly/anomaly_grav/announce()
	GLOB.event_announcement.Announce("Anomalia gravitacional detectada en los escaneres de largo alcance. Ubicacion esperada: [impact_area.name].", "Alerta de Anomalia")

/datum/event/anomaly/anomaly_grav/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/grav(T.loc)
