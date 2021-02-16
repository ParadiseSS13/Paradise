/obj/effect/spawner/window
	name = "window spawner"
	icon = 'icons/obj/structures.dmi'
	icon_state = "window_spawner"
	var/useFull = TRUE
	var/useGrille = TRUE
	var/window_to_spawn_regular = /obj/structure/window/basic
	var/window_to_spawn_full = /obj/structure/window/full/basic
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
			var/obj/structure/window/WI = new window_to_spawn_regular(get_turf(src))
			WI.dir = cdir
	else
		new window_to_spawn_full(get_turf(src))

	if(useGrille)
		new /obj/structure/grille(get_turf(src))

	air_update_turf(TRUE) //atmos can pass otherwise
	return INITIALIZE_HINT_QDEL


/obj/effect/spawner/window/reinforced
	name = "reinforced window spawner"
	icon_state = "rwindow_spawner"
	window_to_spawn_regular = /obj/structure/window/reinforced
	window_to_spawn_full = /obj/structure/window/full/reinforced

/obj/effect/spawner/window/plasma
	name = "plasma window spawner"
	icon_state = "pwindow_spawner"
	window_to_spawn_regular = /obj/structure/window/plasmabasic
	window_to_spawn_full = /obj/structure/window/full/plasmabasic

/obj/effect/spawner/window/reinforced/plasma
	name = "reinforced plasma window spawner"
	icon_state = "prwindow_spawner"
	window_to_spawn_regular = /obj/structure/window/plasmareinforced
	window_to_spawn_full = /obj/structure/window/full/plasmareinforced

/obj/effect/spawner/window/reinforced/tinted
	name = "tinted reinforced window spawner"
	icon_state = "twindow_spawner"
	window_to_spawn_regular = /obj/structure/window/reinforced/tinted
	window_to_spawn_full = /obj/structure/window/full/reinforced/tinted

/obj/effect/spawner/window/shuttle
	name = "shuttle window spawner"
	icon_state = "swindow_spawner"
	window_to_spawn_full = /obj/structure/window/full/shuttle

/obj/effect/spawner/window/shuttle/survival_pod
	name = "pod window spawner"
	icon_state = "podwindow_spawner"
	window_to_spawn_full = /obj/structure/window/full/shuttle/survival_pod

/obj/effect/spawner/window/plastitanium
	name = "plastitanium window spawner"
	icon_state = "plastitaniumwindow_spawner"
	window_to_spawn_full = /obj/structure/window/full/plastitanium

/obj/effect/spawner/window/ice
	name = "ice window spawner"
	icon_state = "icewindow_spawner"
	window_to_spawn_full = /obj/structure/window/full/reinforced/ice
