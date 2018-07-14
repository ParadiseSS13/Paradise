//Fill the whole area with plating.
/datum/mapGeneratorModule/bottomLayer/maintFloor
	spawnableTurfs = list(/turf/simulated/floor/plating = 100)

//Oh my, chances are the whole thing is open to space! Time to build a wall to keep those space mexicans out.
/datum/mapGeneratorModule/space_adjacent/maintWall
	spawnableTurfs = list(/turf/simulated/wall/r_wall = 75,
						  /turf/simulated/wall/r_wall/rust = 5)

/datum/mapGeneratorModule/space_adjacent/maintWall/place(var/turf/T)
	var/newtype = pickweight(spawnableTurfs)
	T.ChangeTurf(newtype)

//Divide it to rooms
/datum/mapGeneratorModule/maintWall
	spawnableTurfs = list(/turf/simulated/wall = 5,
						  /turf/simulated/wall/rust = 1)

/datum/mapGeneratorModule/maintWall/generate()
	if(!mother)
		return

	var/list/map = mother.map
	var/runs = round(map.len ** 0.625) //Let's adjust the number of walls to the size of the area
	for(var/i=1,i<=runs,i++)
		var/dir = pick(NORTH,SOUTH,EAST,WEST)
		var/turf/T = pick(map)

		var/end = rand(3, map.len ** 0.5)
		var/j = 1
		while((T in map) && j <= end) //The area to generate is out of bounds, thus abort the proc
			place(T)
			T = get_step(T, dir)
			j++

/datum/mapGeneratorModule/maintWall/place(var/turf/T)
	if(is_space_adjacent(T) || wall_too_thick(T) || objs_in_turf(T))
		return

	T.ChangeTurf(pickweight(spawnableTurfs))

//Prevents stupidly thick walls
/datum/mapGeneratorModule/maintWall/proc/wall_too_thick(var/turf/T)
	var/amounta = 0
	for(var/D in list(NORTH, EAST, NORTHEAST))
		if(istype(get_step(T, D), /turf/simulated/wall))
			amounta++

	var/amountb = 0
	for(var/D in list(NORTH, WEST, NORTHWEST))
		if(istype(get_step(T, D), /turf/simulated/wall))
			amountb++

	var/amountc = 0
	for(var/D in list(SOUTH, EAST, SOUTHEAST))
		if(istype(get_step(T, D), /turf/simulated/wall))
			amountc++

	var/amountd = 0
	for(var/D in list(SOUTH, WEST, SOUTHWEST))
		if(istype(get_step(T, D), /turf/simulated/wall))
			amountd++

	if(amounta > 2 || amountb > 2 || amountc > 2 || amountd > 2)
		return TRUE
	return FALSE

//Now we have walls, time to put in some doors
/datum/mapGeneratorModule/maintDoor
		spawnableAtoms = list(/obj/effect/spawner/window = 1,
							  /obj/machinery/door/airlock/maintenance = 15,
							  /obj/machinery/door/airlock/welded = 1,
							  /obj/structure/door_assembly/door_assembly_mai = 1,
							  /obj/structure/falsewall = 5,
							  /obj/structure/foamedmetal = 1,
							  /obj/structure/girder = 2,
							  /obj/structure/grille = 6,
							  /obj/structure/grille/broken = 9,
							  /obj/structure/inflatable = 1,
							  /obj/structure/inflatable/door = 1,
							  /obj/structure/mineral_door/wood = 2,
							  /obj/structure/mineral_door/iron = 1,
							  /obj/structure/window/full/basic = 1,
							  /obj/structure/barricade/wooden = 2,
							  /obj/structure/curtain = 1)

/datum/mapGeneratorModule/maintDoor/generate()
	if(!mother)
		return

	var/list/map = mother.map

	for(var/turf/simulated/wall/T in map)
		if(!is_space_adjacent(T) && eligible_door(T) && prob(40))
			if(prob(50))
				place(T)
			else
				T.ChangeTurf(/turf/simulated/floor/plating)

/datum/mapGeneratorModule/maintDoor/proc/eligible_door(var/turf/T)
	if(istype(get_step(T, NORTH),/turf/simulated/wall) && istype(get_step(T, SOUTH),/turf/simulated/wall) && \
	   istype(get_step(T, EAST),/turf/simulated/floor) && istype(get_step(T, WEST),/turf/simulated/floor))
		return TRUE
	else if(istype(get_step(T, EAST),/turf/simulated/wall) && istype(get_step(T, WEST),/turf/simulated/wall) && \
			istype(get_step(T, NORTH),/turf/simulated/floor) && istype(get_step(T, SOUTH),/turf/simulated/floor))
		return TRUE
	return FALSE

/datum/mapGeneratorModule/maintDoor/place(var/turf/T)
	T.ChangeTurf(/turf/simulated/floor/plating)
	var/type = pickweight(spawnableAtoms)
	new type(T)

//Stuff that should be placed randomly basically anywhere that's not a wall.
/datum/mapGeneratorModule/maintFurniture
	spawnableAtoms = list(/obj/effect/decal/cleanable/ash = 5,
						  /obj/effect/decal/cleanable/blood/gibs/robot = 4,
						  /obj/effect/decal/cleanable/blood/oil = 3,
						  /obj/effect/decal/cleanable/blood/splatter = 1,
						  /obj/effect/decal/cleanable/dirt = 5,
						  /obj/effect/decal/cleanable/generic = 5,
						  /obj/effect/decal/cleanable/vomit = 1,
						  /obj/effect/decal/remains = 1,
						  /obj/effect/decal/remains/robot = 2,
						  /obj/effect/particle_effect/sparks = 5,
						  /obj/item/poster/random_contraband = 5,
						  /obj/machinery/constructable_frame/machine_frame = 2,
						  /obj/machinery/space_heater = 3,
						  /obj/machinery/vending/autodrobe = 1,
						  /obj/structure/closet = 6,
						  /obj/structure/closet/crate = 4,
						  /obj/structure/closet/emcloset = 5,
						  /obj/structure/closet/firecloset = 1,
						  /obj/structure/closet/secure_closet/personal = 3,
						  /obj/structure/closet/toolcloset = 1,
						  /obj/structure/closet/wardrobe/black = 2,
						  /obj/structure/closet/wardrobe/mixed = 2,
						  /obj/structure/closet/wardrobe/white = 2,
						  /obj/structure/computerframe = 1,
						  /obj/structure/rack = 8,
						  /obj/structure/reagent_dispensers/fueltank = 10,
						  /obj/structure/reagent_dispensers/watertank = 10,
						  /obj/structure/stool = 9,
						  /obj/structure/stool/bed = 6,
						  /obj/structure/table = 8,
						  /obj/structure/table/glass = 6,
						  /obj/structure/table/reinforced = 1,
						  /obj/structure/table/wood = 8)

/datum/mapGeneratorModule/maintFurniture/place(var/turf/T)
	if(checkPlaceAtom(T) && prob(30))
		var/type = pickweight(spawnableAtoms)
		new type(T)

/datum/mapGeneratorModule/maintFurniture/checkPlaceAtom(var/turf/T)
	return !objs_in_turf(T) && ..()

/datum/mapGeneratorModule/conditional/maintConditionalFurniture
	spawnableAtoms = list(/datum/conditionalGenerator/lootdrop = 25,
						  /datum/conditionalGenerator/lipstick = 1,
						  /datum/conditionalGenerator/pill_bottle = 1,
						  /datum/conditionalGenerator/light = 5,
						  /datum/conditionalGenerator/chair = 8,
						  /datum/conditionalGenerator/cobweb = 3,
						  /datum/conditionalGenerator/fungus = 3)

/datum/mapGeneratorModule/maintWindow
	spawnableAtoms = list(/obj/effect/spawner/window/reinforced = 1)
	spawnableTurfs = list(/turf/simulated/floor/plating = 1)

/datum/mapGeneratorModule/maintWindow/place(var/turf/T)
	if(prob(30) && checkPlaceAtom(T))
		var/type = pickweight(spawnableAtoms)
		new type(T)
		type = pickweight(spawnableTurfs)
		T.ChangeTurf(type)

/datum/mapGeneratorModule/maintWindow/checkPlaceAtom(var/turf/T)
	if(istype(get_step(T, NORTH), /turf/simulated/floor) && istype(get_step(T, SOUTH), /turf/space) || \
	   istype(get_step(T, SOUTH), /turf/simulated/floor) && istype(get_step(T, NORTH), /turf/space) || \
	   istype(get_step(T, WEST), /turf/simulated/floor) && istype(get_step(T, EAST), /turf/space) || \
	   istype(get_step(T, EAST), /turf/simulated/floor) && istype(get_step(T, WEST), /turf/space))
		return TRUE
	return FALSE