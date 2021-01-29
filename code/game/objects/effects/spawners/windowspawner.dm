/obj/effect/spawner/window
	name = "window spawner"
	icon = 'icons/obj/structures.dmi'
	icon_state = "window_spawner"
	var/useFull = TRUE
	var/useGrille = TRUE
	var/windowtospawn = /obj/structure/window/full/basic
	anchored = TRUE // No sliding out while you prime

/obj/effect/spawner/window/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	for(var/obj/structure/grille/G in get_turf(src))
		// Complain noisily
		log_runtime(EXCEPTION("Extra grille on turf: ([T.x],[T.y],[T.z])"), src)
		qdel(G) //just in case mappers don't know what they are doing

	if(!useFull)
		for(var/cdir in GLOB.cardinal)
			for(var/obj/effect/spawner/window/WS in get_step(src,cdir))
				cdir = null
				break
			if(!cdir)
				continue
			var/obj/structure/window/WI = new windowtospawn(get_turf(src))
			WI.dir = cdir
	else
		new windowtospawn(get_turf(src))

	if(useGrille)
		new /obj/structure/grille(get_turf(src))

	air_update_turf(TRUE) //atmos can pass otherwise
	// Give some time for nearby window spawners to initialize
	spawn(10)
		qdel(src)
	// why is this line a no-op
	// QDEL_IN(src, 10)


/obj/effect/spawner/window/reinforced
	name = "reinforced window spawner"
	icon_state = "rwindow_spawner"
	windowtospawn = /obj/structure/window/full/reinforced

/obj/effect/spawner/window/reinforced/plasma
	name = "reinforced plasma window spawner"
	icon_state = "pwindow_spawner"
	windowtospawn = /obj/structure/window/full/plasmareinforced

/obj/effect/spawner/window/shuttle
	name = "shuttle window spawner"
	icon_state = "swindow_spawner"
	windowtospawn = /obj/structure/window/shuttle
