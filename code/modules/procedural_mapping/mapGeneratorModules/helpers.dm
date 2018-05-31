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
		SSair.remove_from_active(T)
	for(var/turf/simulated/T in map)
		if(T.air)
			T.air.oxygen = T.oxygen
			T.air.nitrogen = T.nitrogen
			T.air.carbon_dioxide = T.carbon_dioxide
			T.air.toxins = T.toxins
			T.air.temperature = T.temperature
		SSair.add_to_active(T)

//Only places atoms/turfs on area borders
/datum/mapGeneratorModule/border
	clusterCheckFlags = CLUSTER_CHECK_NONE

/datum/mapGeneratorModule/border/generate()
	if(!mother)
		return
	var/list/map = mother.map
	for(var/turf/T in map)
		if(is_border(T))
			place(T)

/datum/mapGeneratorModule/border/proc/is_border(var/turf/T)
	for(var/direction in list(SOUTH,EAST,WEST,NORTH))
		if(get_step(T,direction) in mother.map)
			continue
		return 1
	return 0

//Only places atoms/turfs on turfs next to space
/datum/mapGeneratorModule/space_adjacent
	clusterCheckFlags = CLUSTER_CHECK_NONE

/datum/mapGeneratorModule/space_adjacent/generate()
	if(!mother)
		return
	var/list/map = mother.map
	for(var/turf/T in map)
		if(is_space_adjacent(T))
			place(T)

/datum/mapGeneratorModule/proc/is_space_adjacent(var/turf/T)
	for(var/D in list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
		if(istype(get_step(T, D), /turf/space))
			return TRUE
	return FALSE

/datum/mapGeneratorModule/proc/objs_in_turf(var/turf/T)
	var/i = 0
	for(var/obj/O in T.contents)
		i++
	return i