// Modules

/datum/map_generator_module/bottom_layer/syndie_floor
	spawnableTurfs = list(/turf/simulated/floor/mineral/plastitanium/red = 100)

/datum/map_generator_module/border/syndie_walls
	spawnableAtoms = list()
	spawnableTurfs = list(/turf/simulated/wall/r_wall = 100)


/datum/map_generator_module/syndie_furniture
	spawnableTurfs = list()
	spawnableAtoms = list(/obj/structure/table = 20,/obj/structure/chair = 15,/obj/structure/chair/stool = 10, \
		/obj/structure/computerframe = 15, /obj/item/storage/toolbox/syndicate = 15 ,\
		/obj/structure/closet/syndicate = 25)

/datum/map_generator_module/splatter_layer/syndie_mobs
	clusterCheckFlags = MAP_GENERATOR_CLUSTER_CHECK_SAME_ATOMS
	spawnableAtoms = list(/mob/living/simple_animal/hostile/syndicate = 50, \
		/mob/living/simple_animal/hostile/syndicate/ranged = 20, \
		/mob/living/basic/viscerator = 30)
	spawnableTurfs = list()

// Generators

/// walls and floor only
/datum/map_generator/syndicate/empty
		modules = list(/datum/map_generator_module/bottom_layer/syndie_floor, \
		/datum/map_generator_module/border/syndie_walls,\
		/datum/map_generator_module/bottom_layer/repressurize)

/datum/map_generator/syndicate/mobsonly
	modules = list(/datum/map_generator_module/bottom_layer/syndie_floor, \
		/datum/map_generator_module/border/syndie_walls,\
		/datum/map_generator_module/splatter_layer/syndie_mobs, \
		/datum/map_generator_module/bottom_layer/repressurize)

/datum/map_generator/syndicate/furniture
	modules = list(/datum/map_generator_module/bottom_layer/syndie_floor, \
		/datum/map_generator_module/border/syndie_walls,\
		/datum/map_generator_module/syndie_furniture, \
		/datum/map_generator_module/bottom_layer/repressurize)

/datum/map_generator/syndicate/full
	modules = list(/datum/map_generator_module/bottom_layer/syndie_floor, \
		/datum/map_generator_module/border/syndie_walls,\
		/datum/map_generator_module/syndie_furniture, \
		/datum/map_generator_module/splatter_layer/syndie_mobs, \
		/datum/map_generator_module/bottom_layer/repressurize)
