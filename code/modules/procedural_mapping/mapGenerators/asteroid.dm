//Asteroid turfs
/datum/map_generator_module/bottom_layer/asteroid_turfs
	spawnableTurfs = list(/turf/simulated/floor/plating/asteroid/airless = 100)

/datum/map_generator_module/bottom_layer/asteroid_walls
	spawnableTurfs = list(/turf/simulated/mineral = 100)

//Border walls
/datum/map_generator_module/border/asteroid_walls
	spawnableAtoms = list()
	spawnableTurfs = list(/turf/simulated/mineral = 100)

//Random walls
/datum/map_generator_module/splatter_layer/asteroid_walls
	clusterCheckFlags = MAP_GENERATOR_CLUSTER_CHECK_NONE
	spawnableAtoms = list()
	spawnableTurfs = list(/turf/simulated/mineral = 30)

//Monsters
/datum/map_generator_module/splatter_layer/asteroid_monsters
	spawnableTurfs = list()
	spawnableAtoms = list(
		/mob/living/basic/mining/basilisk = 10,
		/mob/living/basic/mining/hivelord = 10,
		/mob/living/basic/mining/goliath/space = 10,
	)

// GENERATORS

/datum/map_generator/asteroid/hollow
	modules = list(/datum/map_generator_module/bottom_layer/asteroid_turfs, \
		/datum/map_generator_module/border/asteroid_walls)

/datum/map_generator/asteroid/hollow/random
	modules = list(/datum/map_generator_module/bottom_layer/asteroid_turfs, \
		/datum/map_generator_module/border/asteroid_walls, \
		/datum/map_generator_module/splatter_layer/asteroid_walls)

/datum/map_generator/asteroid/hollow/random/monsters
	modules = list(/datum/map_generator_module/bottom_layer/asteroid_turfs, \
		/datum/map_generator_module/border/asteroid_walls, \
		/datum/map_generator_module/splatter_layer/asteroid_walls, \
		/datum/map_generator_module/splatter_layer/asteroid_monsters)

/datum/map_generator/asteroid/filled
	modules = list(/datum/map_generator_module/bottom_layer/asteroid_walls)
