/turf/simulated/Initialize(mapload)
	. = ..()
	if(!blocks_air)
		blind_set_air(get_initial_air())

/turf/simulated/proc/get_initial_air()
	var/datum/gas_mixture/air = new()
	if(!blocks_air)
		air.set_oxygen(oxygen)
		air.set_carbon_dioxide(carbon_dioxide)
		air.set_nitrogen(nitrogen)
		air.set_toxins(toxins)
		air.set_sleeping_agent(sleeping_agent)
		air.set_agent_b(agent_b)
		air.set_temperature(temperature)
	else
		air.set_oxygen(0)
		air.set_carbon_dioxide(0)
		air.set_nitrogen(0)
		air.set_toxins(0)
		air.set_sleeping_agent(0)
		air.set_agent_b(0)
		air.set_temperature(0)
	return air

/turf/simulated/Destroy()
	QDEL_NULL(active_hotspot)
	QDEL_NULL(wet_overlay)
	return ..()

/turf/simulated/proc/mimic_temperature_solid(turf/model, conduction_coefficient)
	var/delta_temperature = (temperature_archived - model.temperature)
	if((heat_capacity > 0) && (abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER))

		var/heat = conduction_coefficient*delta_temperature* \
			(heat_capacity*model.heat_capacity/(heat_capacity+model.heat_capacity))
		temperature -= heat/heat_capacity

/turf/simulated/proc/share_temperature_mutual_solid(turf/simulated/sharer, conduction_coefficient)
	var/delta_temperature = (temperature_archived - sharer.temperature_archived)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER && heat_capacity && sharer.heat_capacity)

		var/heat = conduction_coefficient*delta_temperature* \
			(heat_capacity*sharer.heat_capacity/(heat_capacity+sharer.heat_capacity))

		temperature -= heat/heat_capacity
		sharer.temperature += heat/sharer.heat_capacity

/turf/simulated/proc/update_visuals()
	var/datum/gas_mixture/air = get_readonly_air()
	var/new_overlay_type = tile_graphic(air)
	if(new_overlay_type == atmos_overlay_type)
		return
	var/atmos_overlay = get_atmos_overlay_by_name(atmos_overlay_type)
	if(atmos_overlay)
		vis_contents -= atmos_overlay
		atmos_overlay_type = null

	atmos_overlay = get_atmos_overlay_by_name(new_overlay_type)
	if(atmos_overlay)
		vis_contents += atmos_overlay
		atmos_overlay_type = new_overlay_type

/turf/simulated/proc/get_atmos_overlay_by_name(name)
	switch(name)
		if("plasma")
			return GLOB.plmaster
		if("sleeping_agent")
			return GLOB.slmaster
	return null

/turf/simulated/proc/tile_graphic(datum/gas_mixture/air)
	if(blocks_air)
		return
	if(!istype(air))
		air = get_readonly_air()
	if(air.toxins() > MOLES_PLASMA_VISIBLE)
		return "plasma"

	if(air.sleeping_agent() > 1)
		return "sleeping_agent"
	return null

/turf/proc/high_pressure_movements(flow_x, flow_y)
	var/atom/movable/M
	for(var/thing in src)
		M = thing
		if(QDELETED(M))
			continue
		if(M.anchored)
			continue
		if(M.pulledby)
			continue
		if(M.last_high_pressure_movement_air_cycle < SSair.times_fired)
			M.experience_pressure_difference(flow_x, flow_y)

/atom/movable/proc/experience_pressure_difference(flow_x, flow_y, pressure_resistance_prob_delta = 0)
	var/const/PROBABILITY_OFFSET = 25
	var/const/PROBABILITY_BASE_PRECENT = 75

	var/pressure_difference = sqrt(flow_x ** 2 + flow_y ** 2)
	var/max_force = sqrt(pressure_difference) * (MOVE_FORCE_DEFAULT / 5)
	set waitfor = 0
	var/move_prob = 100
	if(pressure_resistance > 0)
		move_prob = (pressure_difference / pressure_resistance * PROBABILITY_BASE_PRECENT) - PROBABILITY_OFFSET
	move_prob += pressure_resistance_prob_delta
	if(move_prob > PROBABILITY_OFFSET && prob(move_prob) && (move_resist != INFINITY) && (!anchored && (max_force >= (move_resist * MOVE_FORCE_PUSH_RATIO))) || (anchored && (max_force >= (move_resist * MOVE_FORCE_FORCEPUSH_RATIO))))
		var/direction = 0
		if(flow_x > 0.5)
			direction |= EAST
		if(flow_x < -0.5)
			direction |= WEST
		if(flow_y > 0.5)
			direction |= NORTH
		if(flow_y < -0.5)
			direction |= SOUTH
		step(src, direction)
		last_high_pressure_movement_air_cycle = SSair.times_fired

	return pressure_difference

/turf/simulated/proc/radiate_to_spess() //Radiate excess tile heat to space
	if(temperature > T0C) //Considering 0 degC as te break even point for radiation in and out
		var/delta_temperature = (temperature_archived - TCMB) //hardcoded space temperature
		if((heat_capacity > 0) && (abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER))

			var/heat = thermal_conductivity*delta_temperature* \
				(heat_capacity*HEAT_CAPACITY_VACUUM/(heat_capacity+HEAT_CAPACITY_VACUUM)) //700000 is the heat_capacity from a space turf, hardcoded here
			temperature -= heat/heat_capacity

#define INDEX_NORTH	1
#define INDEX_EAST	2
#define INDEX_SOUTH	3
#define INDEX_WEST	4

/turf/proc/Initialize_Atmos(times_fired)
	recalculate_atmos_connectivity()

	if(!blocks_air)
		var/datum/gas_mixture/air = new()
		air.set_oxygen(oxygen)
		air.set_carbon_dioxide(carbon_dioxide)
		air.set_nitrogen(nitrogen)
		air.set_toxins(toxins)
		air.set_sleeping_agent(sleeping_agent)
		air.set_agent_b(agent_b)
		air.set_temperature(temperature)
		blind_set_air(air)

/turf/proc/recalculate_atmos_connectivity()
	var/datum/milla_safe/recalculate_atmos_connectivity/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/recalculate_atmos_connectivity

/datum/milla_safe/recalculate_atmos_connectivity/on_run(turf/T)
	if(isnull(T))
		return

	if(T.blocks_air)
		set_tile_airtight(T, list(TRUE, TRUE, TRUE, TRUE))
		// Will be needed when we go back to having solid tile conductivity.
		//reset_superconductivity(src)
		reduce_superconductivity(T, list(0, 0, 0, 0))
		return

	var/list/atmos_airtight = list(
		!T.CanAtmosPass(NORTH, FALSE),
		!T.CanAtmosPass(EAST, FALSE),
		!T.CanAtmosPass(SOUTH, FALSE),
		!T.CanAtmosPass(WEST, FALSE))

	var/list/superconductivity = list(
		OPEN_HEAT_TRANSFER_COEFFICIENT,
		OPEN_HEAT_TRANSFER_COEFFICIENT,
		OPEN_HEAT_TRANSFER_COEFFICIENT,
		OPEN_HEAT_TRANSFER_COEFFICIENT)

	for(var/obj/O in T)
		if(istype(O, /obj/item))
			// Items can't block atmos.
			continue
		if(!O.CanAtmosPass(NORTH))
			atmos_airtight[INDEX_NORTH] = TRUE
		if(!O.CanAtmosPass(EAST))
			atmos_airtight[INDEX_EAST] = TRUE
		if(!O.CanAtmosPass(SOUTH))
			atmos_airtight[INDEX_SOUTH] = TRUE
		if(!O.CanAtmosPass(WEST))
			atmos_airtight[INDEX_WEST] = TRUE
		superconductivity[INDEX_NORTH] = min(superconductivity[INDEX_NORTH], O.get_superconductivity(NORTH))
		superconductivity[INDEX_EAST] = min(superconductivity[INDEX_EAST], O.get_superconductivity(EAST))
		superconductivity[INDEX_SOUTH] = min(superconductivity[INDEX_SOUTH], O.get_superconductivity(SOUTH))
		superconductivity[INDEX_WEST] = min(superconductivity[INDEX_WEST], O.get_superconductivity(WEST))

	set_tile_airtight(T, atmos_airtight)
	reset_superconductivity(T)
	reduce_superconductivity(T, superconductivity)

#undef INDEX_NORTH
#undef INDEX_EAST
#undef INDEX_SOUTH
#undef INDEX_WEST
