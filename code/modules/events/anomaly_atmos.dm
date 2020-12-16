/datum/event/anomaly/anomaly_atmos
	startWhen = 30
	announceWhen = 3
	endWhen = 100

/datum/event/anomaly/anomaly_atmos/announce()
	GLOB.event_announcement.Announce("Transformative gas anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")

/datum/event/anomaly/anomaly_atmos/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/atmos(T.loc)


/datum/event/anomaly/anomaly_atmos/tick()
	if(!newAnomaly)
		kill()
		return
	if(ISMULTIPLE(activeFor, 5))
		newAnomaly.anomalyEffect()

/datum/event/anomaly/anomaly_atmos/end()
	if(!newAnomaly || !newAnomaly.loc)	//no anomaly or it is in nullspace
		return
	var/obj/effect/anomaly/atmos/A = newAnomaly
	var/gas_type = A.gas_type
	var/area/t_area = get_area(A)
	for(var/turf/T in t_area)
		if(istype(T, /turf/simulated))	//should not occur on unsimulated turfs without admemery
			var/turf/simulated/S = T
			fill_with_gas(gas_type, S)
	explosion(get_turf(newAnomaly), -1, 0, 2)	// a small boom so people know something happened.
	..()

/**
  * Replaces all oxygen and nitrogen on the simulated turf S with the gas type specified in gas, taking N2, N20, CO2 and agent B
  */
/datum/event/anomaly/anomaly_atmos/proc/fill_with_gas(gas, turf/simulated/S)
	if(!S.air)//no air to transform
		return
	var/amount_to_add = S.air.oxygen + S.air.nitrogen
	S.air.oxygen = 0
	S.air.nitrogen = 0
	switch(gas)
		if(GAS_N2)
			S.air.nitrogen += amount_to_add
		if(GAS_N2O)
			S.air.sleeping_agent += amount_to_add
		if(GAS_CO2)
			S.air.carbon_dioxide += amount_to_add
	S.update_visuals()
	S.air_update_turf()
