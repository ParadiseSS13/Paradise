// Modules

/turf/simulated/shuttle/floor/syndicate //TODO: move to proper file/replace syndie shuttle turfs
	icon_state = "floor4"

/datum/mapGeneratorModule/bottomLayer/syndieFloor
	spawnableTurfs = list(/turf/simulated/shuttle/floor/syndicate = 100)

/datum/mapGeneratorModule/border/syndieWalls
	spawnableAtoms = list()
	spawnableTurfs = list(/turf/simulated/wall/r_wall = 100)


/datum/mapGeneratorModule/syndieFurniture
	clusterCheckFlags = CLUSTER_CHECK_SAME_ATOMS
	spawnableTurfs = list()
	spawnableAtoms = list(/obj/structure/table = 20,/obj/structure/chair = 15,/obj/structure/chair/stool = 10, \
		/obj/structure/computerframe = 15, /obj/item/storage/toolbox/syndicate = 15 ,\
		/obj/structure/closet/syndicate = 25)

/datum/mapGeneratorModule/splatterLayer/syndieMobs
	clusterCheckFlags = CLUSTER_CHECK_SAME_ATOMS
	spawnableAtoms = list(/mob/living/simple_animal/hostile/syndicate = 30, \
		/mob/living/simple_animal/hostile/syndicate/melee = 20, \
		/mob/living/simple_animal/hostile/syndicate/ranged = 20, \
		/mob/living/simple_animal/hostile/viscerator = 30)
	spawnableTurfs = list()

// Generators

/datum/mapGenerator/syndicate/empty //walls and floor only
		modules = list(/datum/mapGeneratorModule/bottomLayer/syndieFloor, \
		/datum/mapGeneratorModule/border/syndieWalls,\
		/datum/mapGeneratorModule/bottomLayer/repressurize)

/datum/mapGenerator/syndicate/mobsonly
	modules = list(/datum/mapGeneratorModule/bottomLayer/syndieFloor, \
		/datum/mapGeneratorModule/border/syndieWalls,\
		/datum/mapGeneratorModule/splatterLayer/syndieMobs, \
		/datum/mapGeneratorModule/bottomLayer/repressurize)

/datum/mapGenerator/syndicate/furniture
	modules = list(/datum/mapGeneratorModule/bottomLayer/syndieFloor, \
		/datum/mapGeneratorModule/border/syndieWalls,\
		/datum/mapGeneratorModule/syndieFurniture, \
		/datum/mapGeneratorModule/bottomLayer/repressurize)

/datum/mapGenerator/syndicate/full
	modules = list(/datum/mapGeneratorModule/bottomLayer/syndieFloor, \
		/datum/mapGeneratorModule/border/syndieWalls,\
		/datum/mapGeneratorModule/syndieFurniture, \
		/datum/mapGeneratorModule/splatterLayer/syndieMobs, \
		/datum/mapGeneratorModule/bottomLayer/repressurize)
