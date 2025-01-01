//Helper Modules


// Helper to repressurize the area in case it was run in space
/datum/map_generator_module/bottom_layer/repressurize
	spawnableAtoms = list()
	spawnableTurfs = list()

/datum/map_generator_module/bottom_layer/repressurize/generate()
	if(!mother)
		return
	var/list/map = mother.map
	for(var/turf/simulated/T in map)
		var/datum/gas_mixture/air = new()
		air.set_oxygen(T.oxygen)
		air.set_nitrogen(T.nitrogen)
		air.set_carbon_dioxide(T.carbon_dioxide)
		air.set_toxins(T.toxins)
		air.set_sleeping_agent(T.sleeping_agent)
		air.set_agent_b(T.agent_b)
		air.set_temperature(T.temperature)
		T.blind_set_air(air)

//Only places atoms/turfs on area borders
/datum/map_generator_module/border
	clusterCheckFlags = MAP_GENERATOR_CLUSTER_CHECK_NONE

/datum/map_generator_module/border/generate()
	if(!mother)
		return
	var/list/map = mother.map
	for(var/turf/T in map)
		if(is_border(T))
			place(T)

/datum/map_generator_module/border/proc/is_border(turf/T)
	for(var/direction in list(SOUTH,EAST,WEST,NORTH))
		if(get_step(T,direction) in mother.map)
			continue
		return 1
	return 0
