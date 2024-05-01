//Helper Modules


// Helper to repressurize the area in case it was run in space
/datum/mapGeneratorModule/bottomLayer/repressurize
	spawnableAtoms = list()
	spawnableTurfs = list()

/datum/mapGeneratorModule/bottomLayer/repressurize/generate()
	if(!mother)
		return
	var/list/map = mother.map
	for(var/turf/simulated/T in map)
		if(!T.blocks_air)
			var/datum/gas_mixture/T_air = T.read_air()
			T_air.oxygen = T.oxygen
			T_air.nitrogen = T.nitrogen
			T_air.carbon_dioxide = T.carbon_dioxide
			T_air.toxins = T.toxins
			T_air.sleeping_agent = T.sleeping_agent
			T_air.agent_b = T.agent_b
			T_air.temperature = T.temperature
			T.write_air(T_air)

//Only places atoms/turfs on area borders
/datum/mapGeneratorModule/border
	clusterCheckFlags = MAP_GENERATOR_CLUSTER_CHECK_NONE

/datum/mapGeneratorModule/border/generate()
	if(!mother)
		return
	var/list/map = mother.map
	for(var/turf/T in map)
		if(is_border(T))
			place(T)

/datum/mapGeneratorModule/border/proc/is_border(turf/T)
	for(var/direction in list(SOUTH,EAST,WEST,NORTH))
		if(get_step(T,direction) in mother.map)
			continue
		return 1
	return 0
