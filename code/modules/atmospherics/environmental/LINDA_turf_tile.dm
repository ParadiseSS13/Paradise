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
	QDEL_NULL(wind_effect)
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
	for(var/atom/movable/M in src)
		if(QDELETED(M))
			continue
		if(M.anchored)
			continue
		if(M.pulledby)
			continue
		M.experience_pressure_difference(flow_x, flow_y)

/proc/wind_direction(flow_x, flow_y)
	var/direction = 0
	if(flow_x > 0.5)
		direction |= EAST
	if(flow_x < -0.5)
		direction |= WEST
	if(flow_y > 0.5)
		direction |= NORTH
	if(flow_y < -0.5)
		direction |= SOUTH

	return direction

/atom/movable/proc/experience_pressure_difference(flow_x, flow_y)
	if(move_resist == INFINITY)
		return

	var/force_needed = max(move_resist, 1)
	if(anchored)
		force_needed *= MOVE_FORCE_FORCEPUSH_RATIO
	else
		force_needed *= MOVE_FORCE_PUSH_RATIO

	var/turf/my_turf = get_turf(src)
	var/datum/gas_mixture/my_air = my_turf.get_readonly_air()

	var/air = my_air.total_moles() / MOLES_CELLSTANDARD
	var/wind = sqrt(flow_x ** 2 + flow_y ** 2)
	var/force = wind * air * (MOVE_FORCE_DEFAULT / 5)

	if(force < force_needed)
		return

	var/direction = wind_direction(flow_x, flow_y)
	if(direction == 0)
		return

	if(last_high_pressure_movement_time >= SSair.times_fired - 3)
		return
	last_high_pressure_movement_time = SSair.times_fired

	air_push(direction, (force - force_needed) / force_needed)

/atom/movable/proc/air_push(direction, strength)
	step(src, direction)

/mob/living/air_push(direction, strength)
	if(HAS_TRAIT(src, TRAIT_MAGPULSE))
		return

	apply_status_effect(STATUS_EFFECT_UNBALANCED)
	apply_status_effect(STATUS_EFFECT_DIRECTIONAL_SLOW, 1 SECONDS, REVERSE_DIR(direction), min(10, strength * 5))

	if(client?.input_data?.desired_move_dir)
		return
	if(!pulling)
		return ..()

	// Make sure we don't let go of something just because the wind pushed us into it.
	var/atom/movable/was_pulling = pulling
	. = ..()
	// We were just pulling it, so we can skip all the other stuff in start_pulling and just re-establish the pull.
	pulling = was_pulling
	was_pulling.pulledby = src

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

/obj/effect/wind
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/tile_effects.dmi'
	icon_state = "wind"
	layer = MASSIVE_OBJ_LAYER
	blend_mode = BLEND_OVERLAY

#undef INDEX_NORTH
#undef INDEX_EAST
#undef INDEX_SOUTH
#undef INDEX_WEST
