/datum/conditionalGenerator/lootdrop
	spawntype = /obj/effect/spawner/lootdrop/maintenance

/datum/conditionalGenerator/lootdrop/condition(var/turf/T)
	if(!objs_in_turf(T) && istype(T, /turf/simulated/floor))
		return TRUE
	return FALSE

/datum/conditionalGenerator/lipstick
	spawntype = /obj/item/lipstick/random

/datum/conditionalGenerator/lipstick/condition(var/turf/T)
	if(!objs_in_turf(T) && istype(T, /turf/simulated/floor))
		return TRUE
	return FALSE

/datum/conditionalGenerator/pill_bottle
	spawntype = /obj/item/storage/pill_bottle/random_drug_bottle

/datum/conditionalGenerator/pill_bottle/condition(var/turf/T)
	if(!objs_in_turf(T) && istype(T, /turf/simulated/floor))
		return TRUE
	return FALSE

/datum/conditionalGenerator/chair/condition(var/turf/T)
	spawntype = pickweight(list(/obj/structure/stool/bed/chair = 8,
					  	   /obj/structure/stool/bed/chair/office/dark = 3,
					  	   /obj/structure/stool/bed/chair/wood/normal = 3,
					  	   /obj/structure/stool/bed/chair/wood/wings = 1))
	dir = pick(NORTH, SOUTH, EAST, WEST)

	if(!objs_in_turf(T) && istype(T, /turf/simulated/floor))
		return TRUE
	return FALSE

/datum/conditionalGenerator/light/condition(var/turf/T)
	spawntype = pick(/obj/machinery/light,
				/obj/machinery/light/small,
				/obj/machinery/light_construct,
				/obj/machinery/light_construct/small)

	var/list/walls = list()
	for(var/D in list(NORTH,EAST,SOUTH,WEST))
		if(istype(get_step(T, D), /turf/simulated/wall))
			walls += D

	if(!objs_in_turf(T) && walls.len > 0 && istype(T, /turf/simulated/floor))
		dir = pick(walls)
		return TRUE
	return FALSE

/datum/conditionalGenerator/cobweb/condition(var/turf/T)
	if(istype(T, /turf/simulated/floor) && istype(get_step(T, NORTH), /turf/simulated/wall) && istype(get_step(T, WEST), /turf/simulated/wall))
		spawntype = /obj/effect/decal/cleanable/cobweb
		return TRUE
	else if(istype(T, /turf/simulated/floor) && istype(get_step(T, NORTH), /turf/simulated/wall) && istype(get_step(T, EAST), /turf/simulated/wall) && istype(T, /turf/simulated/floor))
		spawntype = /obj/effect/decal/cleanable/cobweb2
		return TRUE
	return FALSE

/datum/conditionalGenerator/fungus
	spawntype = /obj/effect/decal/cleanable/fungus

/datum/conditionalGenerator/fungus/condition(var/turf/T)
	if(istype(T, /turf/simulated/wall))
		return TRUE
	return FALSE

/datum/conditionalGenerator/poster
	spawntype = /obj/structure/sign/poster/contraband/random

/datum/conditionalGenerator/poster/condition(var/turf/T)
	if(istype(T, /turf/simulated/wall))
		return TRUE
	return FALSE




//I know that this is an ugly duplicate, but I have no idea where else to place this. I guess this is better than making a
//global proc. If not, God help us all.
/datum/conditionalGenerator/proc/objs_in_turf(var/turf/T)
	var/i = 0
	for(var/obj/O in T.contents)
		i++
	return i