/obj/effect/spawner/random/barrier
	name = "random barrier spawner"
	icon_state = "barrier"
	loot = list(
		/obj/effect/spawner/window/reinforced,
		/obj/machinery/door/airlock,
		/obj/machinery/door/airlock/welded,
		/obj/structure/barricade/wooden,
		/obj/structure/falsewall,
		/turf/simulated/wall,
	)

/obj/effect/spawner/random/barrier/temporary
	name = "random temporary barrier spawner"
	loot = list(
		/obj/structure/barricade/wooden,
		/obj/structure/grille,
		/obj/structure/grille/broken,
		/obj/structure/girder,
		/obj/structure/barricade/security,
		/obj/structure/barricade/sandbags,
	)

/obj/effect/spawner/random/barrier/wall_probably
	name = "probably a wall"
	icon_state = "wall"
	loot = list(
		/obj/structure/falsewall = 1,
		/turf/simulated/wall = 9,
	)

/obj/effect/spawner/random/barrier/obstruction
	name = "obstruction"
	loot = list(
		/obj/machinery/door/airlock/welded,
		/obj/structure/barricade/wooden,
		/obj/structure/falsewall,
		/turf/simulated/wall,
	)

/// these have no access restrictions, so for internal maintenance only
/obj/effect/spawner/random/barrier/possibly_welded_airlock
	name = "possibly welded airlock"
	icon_state = "airlock"
	loot = list(
		/obj/machinery/door/airlock = 3,
		/obj/machinery/door/airlock/welded = 1,
	)

/obj/effect/spawner/random/barrier/grille_often
	name = "grille often"
	icon_state = "grille"
	spawn_loot_chance = 85
	loot = list(
		/obj/structure/grille = 2,
		/obj/structure/grille/broken = 1,
	)

/obj/effect/spawner/random/barrier/grille_maybe
	name = "grille maybe"
	icon_state = "grille"
	spawn_loot_chance = 45
	loot = list(
		/obj/structure/grille,
		/obj/structure/grille/broken,
	)
