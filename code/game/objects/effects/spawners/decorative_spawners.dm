/obj/effect/spawner/random_spawners
	name = "random spawners"
	icon = 'icons/effects/spawner_icons.dmi'
	icon_state = "questionmark"
	var/list/result = list(
	/datum/nothing = 1,
	/obj/effect/decal/cleanable/blood/splatter = 1,
	/obj/effect/decal/cleanable/blood/oil = 1,
	/obj/effect/decal/cleanable/fungus = 1)
	var/spawn_inside = null

// This needs to use New() instead of Initialize() because the thing it creates might need to be initialized too
// AA 2022-08-11: The above comment doesnt even make sense. If extra atoms are loaded during SSatoms.Initialize(), they still get initialised!
/obj/effect/spawner/random_spawners/New()
	. = ..()
	var/turf/T = get_turf(src)
	if(!T)
		stack_trace("Spawner placed in nullspace!")
		return
	randspawn(T)

/obj/effect/spawner/random_spawners/proc/randspawn(turf/T)
	var/thing_to_place = pickweight(result)
	if(ispath(thing_to_place, /datum/nothing))
		// Nothing.
		qdel(src) // See line 13, this needs moving to /Initialize() so we can use the qdel hint already
		return
	else if(ispath(thing_to_place, /turf))
		T.ChangeTurf(thing_to_place)
	else
		if(ispath(spawn_inside, /obj))
			var/obj/O = new thing_to_place(T)
			var/obj/E = new spawn_inside(T)
			O.forceMove(E)
		else
			new thing_to_place(T)
	qdel(src)

/obj/effect/spawner/random_spawners/blood_maybe
	name = "blood maybe"
	icon_state = "blood"
	result = list(
	/datum/nothing = 20,
	/obj/effect/decal/cleanable/blood/splatter = 1)

/obj/effect/spawner/random_spawners/blood_often
	name = "blood often"
	icon_state = "blood"
	result = list(
	/datum/nothing = 5,
	/obj/effect/decal/cleanable/blood/splatter = 1)

/obj/effect/spawner/random_spawners/oil_maybe
	name = "oil maybe"
	icon_state = "oil"
	result = list(
	/datum/nothing = 20,
	/obj/effect/decal/cleanable/blood/oil = 1)

/obj/effect/spawner/random_spawners/oil_often
	name = "oil often"
	icon_state = "oil"
	result = list(
	/datum/nothing = 5,
	/obj/effect/decal/cleanable/blood/oil = 1)

/obj/effect/spawner/random_spawners/cobweb_left_frequent
	name = "cobweb left frequent"
	icon_state = "cobwebl"
	result = list(
	/datum/nothing = 1,
	/obj/effect/decal/cleanable/cobweb = 1)

/obj/effect/spawner/random_spawners/cobweb_right_frequent
	name = "cobweb right frequent"
	icon_state = "cobwebr"
	result = list(
	/datum/nothing = 1,
	/obj/effect/decal/cleanable/cobweb2 = 1)

/obj/effect/spawner/random_spawners/cobweb_left_rare
	name = "cobweb left rare"
	icon_state = "cobwebl"
	result = list(
	/datum/nothing = 10,
	/obj/effect/decal/cleanable/cobweb = 1)

/obj/effect/spawner/random_spawners/cobweb_right_rare
	name = "cobweb right rare"
	icon_state = "cobwebr"
	result = list(
	/datum/nothing = 10,
	/obj/effect/decal/cleanable/cobweb2 = 1)

/obj/effect/spawner/random_spawners/dirt_frequent
	name = "dirt frequent"
	icon_state = "dirt"
	result = list(
	/datum/nothing = 1,
	/obj/effect/decal/cleanable/dirt = 1)

/obj/effect/spawner/random_spawners/dirt_often
	name = "dirt often"
	icon_state = "dirt"
	result = list(
	/datum/nothing = 5,
	/obj/effect/decal/cleanable/dirt = 1)

/obj/effect/spawner/random_spawners/dirt_maybe
	name = "dirt maybe"
	icon_state = "dirt"
	result = list(
	/datum/nothing = 7,
	/obj/effect/decal/cleanable/dirt = 1)

/obj/effect/spawner/random_spawners/fungus_maybe
	name = "fungus maybe"
	icon_state = "fungus"
	color = "#D5820B"
	result = list(
		/datum/nothing = 7,
		/obj/effect/decal/cleanable/fungus = 1)

/obj/effect/spawner/random_spawners/fungus_probably
	name = "fungus probably"
	icon_state = "fungus"
	color = "#D5820B"
	result = list(
		/datum/nothing = 1,
		/obj/effect/decal/cleanable/fungus = 7)

