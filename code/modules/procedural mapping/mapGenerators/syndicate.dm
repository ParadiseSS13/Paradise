// Modules

/turf/simulated/shuttle/floor/syndicate //TODO: move to proper file/replace syndie shuttle turfs
	icon_state = "floor4"

/datum/mapGeneratorModule/bottomLayer/syndieFloor
	spawnableTurfs = list(/turf/simulated/shuttle/floor/syndicate = 100)

/datum/mapGeneratorModule/border/syndieWalls
	spawnableAtoms = list()
	spawnableTurfs = list(/turf/simulated/wall/r_wall = 100)


/datum/mapGeneratorModule/bottomLayer/repressurize
	// Helper to repressurize the area in case it was run in space
	spawnableAtoms = list()
	spawnableTurfs = list()

/datum/mapGeneratorModule/bottomLayer/repressurize/generate()
	if(!mother)
		return
	var/list/map = mother.map
	for(var/turf/simulated/T in map)
		air_master.remove_from_active(T)
	for(var/turf/simulated/T in map)
		if(T.air)
			T.air.oxygen = T.oxygen
			T.air.nitrogen = T.nitrogen
			T.air.carbon_dioxide = T.carbon_dioxide
			T.air.toxins = T.toxins
			T.air.temperature = T.temperature
		air_master.add_to_active(T)

// Generators

/datum/mapGenerator/syndicate/empty //walls and floor only
		modules = list(/datum/mapGeneratorModule/bottomLayer/syndieFloor, \
		/datum/mapGeneratorModule/border/syndieWalls,\
		/datum/mapGeneratorModule/bottomLayer/repressurize)

/*
/datum/mapGenerator/syndicate/syndiesonly //walls/floors + mobs
/datum/mapGenerator/syndicate/full //doors + random equipment
*/