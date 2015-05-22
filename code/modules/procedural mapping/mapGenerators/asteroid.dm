//Border walls
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
		if (get_step(T,direction) in mother.map)
			continue
		return 1
	return 0

//Asteroid turfs
/datum/mapGeneratorModule/bottomLayer/asteroidTurfs
	spawnableTurfs = list(/turf/simulated/floor/plating/airless/asteroid = 100)

/datum/mapGeneratorModule/bottomLayer/asteroidWalls
	spawnableTurfs = list(/turf/simulated/mineral = 100)

//Border walls
/datum/mapGeneratorModule/border/asteroidWalls
	spawnableAtoms = list()
	spawnableTurfs = list(/turf/simulated/mineral = 100)

//Random walls
/datum/mapGeneratorModule/splatterLayer/asteroidWalls
	clusterCheckFlags = CLUSTER_CHECK_NONE
	spawnableAtoms = list()
	spawnableTurfs = list(/turf/simulated/mineral = 30)

//Monsters
/datum/mapGeneratorModule/splatterLayer/asteroidMonsters
	spawnableTurfs = list()
	spawnableAtoms = list(/mob/living/simple_animal/hostile/asteroid/basilisk = 10, \
		/mob/living/simple_animal/hostile/asteroid/hivelord = 10, \
		/mob/living/simple_animal/hostile/asteroid/goliath = 10)


// GENERATORS

/datum/mapGenerator/asteroid/hollow
	modules = list(/datum/mapGeneratorModule/bottomLayer/asteroidTurfs, \
		/datum/mapGeneratorModule/border/asteroidWalls)

/datum/mapGenerator/asteroid/hollow/random
	modules = list(/datum/mapGeneratorModule/bottomLayer/asteroidTurfs, \
		/datum/mapGeneratorModule/border/asteroidWalls, \
		/datum/mapGeneratorModule/splatterLayer/asteroidWalls)

/datum/mapGenerator/asteroid/hollow/random/monsters
	modules = list(/datum/mapGeneratorModule/bottomLayer/asteroidTurfs, \
		/datum/mapGeneratorModule/border/asteroidWalls, \
		/datum/mapGeneratorModule/splatterLayer/asteroidWalls, \
		/datum/mapGeneratorModule/splatterLayer/asteroidMonsters)

/datum/mapGenerator/asteroid/filled
	modules = list(/datum/mapGeneratorModule/bottomLayer/asteroidWalls)