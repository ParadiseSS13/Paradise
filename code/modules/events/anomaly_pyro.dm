/datum/event/anomaly/anomaly_pyro
	startWhen = 30
	announceWhen = 3
	endWhen = 110

/datum/event/anomaly/anomaly_pyro/announce()
	event_announcement.Announce("Atmospheric anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")

/datum/event/anomaly/anomaly_pyro/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/pyro(T.loc)

/datum/event/anomaly/anomaly_pyro/tick()
	if(!newAnomaly)
		kill()
		return
	if(IsMultiple(activeFor, 5))
		newAnomaly.anomalyEffect()

/datum/event/anomaly/anomaly_pyro/end()
	if(newAnomaly.loc)
		explosion(get_turf(newAnomaly), -1,0,3, flame_range = 4)

		var/turf/T = get_turf(src)
		var/new_colour = pick("red", "orange")
		var/mob/living/simple_animal/slime/S = new(T, new_colour)
		S.rabid = TRUE
		S.amount_grown = SLIME_EVOLUTION_THRESHOLD
		S.Evolve()
		qdel(newAnomaly)