/obj/effect/spawner/window
	name = "window spawner"
	icon = 'icons/obj/structures.dmi'
	icon_state = "window_spawner"
	var/useFull = 0
	var/useGrille = 1
	var/windowtospawn = /obj/structure/window/basic
	anchored = 1 // No sliding out while you prime

/obj/effect/spawner/window/Initialize()
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
			if(!cdir)	continue
			var/obj/structure/window/WI = new windowtospawn(get_turf(src))
			sync_id(WI)
			WI.dir = cdir
	else
		var/obj/structure/window/W = new windowtospawn(get_turf(src))
		W.dir = SOUTHWEST

	if(useGrille)
		new /obj/structure/grille(get_turf(src))

	air_update_turf(1) //atmos can pass otherwise
	// Give some time for nearby window spawners to initialize
	spawn(10)
		qdel(src)
	// why is this line a no-op
	// QDEL_IN(src, 10)

/obj/effect/spawner/window/proc/sync_id(obj/structure/window/reinforced/polarized/W)
	return


/obj/effect/spawner/window/reinforced
	name = "reinforced window spawner"
	icon_state = "rwindow_spawner"
	windowtospawn = /obj/structure/window/reinforced

/obj/effect/spawner/window/reinforced/polarized
	name = "polarized reinforced window spawner"
	icon_state = "ewindow_spawner"
	windowtospawn = /obj/structure/window/reinforced/polarized
	/// Used to link electrochromic windows to buttons
	var/id

/obj/effect/spawner/window/reinforced/polarized/sync_id(obj/structure/window/reinforced/polarized/W)
	W.id = id

/obj/effect/spawner/window/reinforced/plasma
	name = "reinforced plasma window spawner"
	icon_state = "pwindow_spawner"
	windowtospawn = /obj/structure/window/plasmareinforced

// Хоть я и сделала ниже рабочие спавнеры окон шаттлов, но по неясной мне причине,
// атмос пропускает воздух через заспавненные им окна...
// Поэтому воздержитесь от их использования, либо найдите и почините баг это вызывающий :)
/obj/effect/spawner/window/shuttle
	name = "shuttle window spawner"
	icon = 'icons/obj/smooth_structures/shuttle_window.dmi'
	icon_state = "shuttle_window"
	useFull = TRUE
	windowtospawn = /obj/structure/window/full/shuttle

/obj/effect/spawner/window/shuttle/gray
	icon = 'icons/obj/smooth_structures/shuttle_window_gray.dmi'
	icon_state = "shuttle_window_gray"
	windowtospawn = /obj/structure/window/full/shuttle/gray

/obj/effect/spawner/window/shuttle/ninja
	icon = 'icons/obj/smooth_structures/shuttle_window_ninja.dmi'
	icon_state = "shuttle_window_ninja"
	windowtospawn = /obj/structure/window/full/shuttle/ninja
