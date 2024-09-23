/obj/effect/spawner/random_barrier
	name = "random tile"
	icon = 'icons/effects/spawner_icons.dmi'
	icon_state = "questionmark"
	var/list/result = list(
	/turf/simulated/floor/plasteel = 1,
	/turf/simulated/wall = 1,
	/obj/structure/falsewall = 1,
	/obj/effect/spawner/window/reinforced = 1,
	/obj/machinery/door/airlock = 1,
	/obj/machinery/door/airlock/welded = 1,
	/obj/structure/barricade/wooden = 1)

// This needs to come before the initialization wave because
// the thing it creates might need to be initialized too
/obj/effect/spawner/random_barrier/Initialize()
	. = ..()
	var/turf/T = get_turf(src)
	if(!T)
		CRASH("Barrier spawner placed in nullspace!")
	var/thing_to_place = pickweight(result)
	if(ispath(thing_to_place, /turf))
		T.ChangeTurf(thing_to_place)
	else
		new thing_to_place(T)
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/random_barrier/wall_probably
	name = "probably a wall"
	icon_state = "girder"
	result = list(
	/turf/simulated/wall = 9,
	/obj/structure/falsewall = 1)

/obj/effect/spawner/random_barrier/floor_probably
	name = "probably a floor"
	result = list(
	/turf/simulated/floor/plasteel = 3,
	/turf/simulated/wall = 1)

/obj/effect/spawner/random_barrier/obstruction
	name = "obstruction"
	icon_state = "barrier"
	result = list(
	/turf/simulated/wall = 1,
	/obj/structure/falsewall = 1,
	/obj/structure/barricade/wooden = 1,
	/obj/machinery/door/airlock/welded = 1)

/// these have no access restrictions, so for internal maintenance only
/obj/effect/spawner/random_barrier/possibly_welded_airlock
	name = "possibly welded airlock"
	icon_state = "airlock"
	result = list(
	/obj/machinery/door/airlock = 3,
	/obj/machinery/door/airlock/welded = 1)

/obj/effect/spawner/random_spawners/grille_often
	name = "grille often"
	icon_state = "grille"
	result = list(
	/obj/structure/grille = 8,
	/obj/structure/grille/broken = 4,
	/turf/simulated/floor/plating = 2)

/obj/effect/spawner/random_spawners/grille_maybe
	name = "grille maybe"
	icon_state = "grille"
	result = list(
	/obj/structure/grille = 2,
	/obj/structure/grille/broken = 2,
	/turf/simulated/floor/plating = 5)
