/obj/effect/spawner/window
	name = "window spawner"
	icon = 'icons/obj/structures.dmi'
	icon_state = "window_spawner"
	var/useFull = TRUE
	var/useGrille = FALSE
	var/window_to_spawn_regular = /obj/structure/window/basic
	var/window_to_spawn_full = /obj/structure/window/full/basic

/obj/effect/spawner/window/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	var/obj/structure/window/WI
	for(var/obj/structure/grille/G in get_turf(src))
		// Complain noisily
		stack_trace("Extra grille on turf: ([T.x],[T.y],[T.z])")
		qdel(G) //just in case mappers don't know what they are doing

	if(!useFull)
		for(var/cdir in GLOB.cardinal)
			for(var/obj/effect/spawner/window/WS in get_step(src,cdir))
				cdir = null
				break
			if(!cdir)
				continue
			WI = new window_to_spawn_regular(get_turf(src))
			WI.dir = cdir
	else
		WI = new window_to_spawn_full(get_turf(src))
	synchronize_variables(WI)

	if(useGrille)
		new /obj/structure/grille(get_turf(src))

	recalculate_atmos_connectivity() //atmos can pass otherwise
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/window/grilled
	useGrille = TRUE
	icon_state = "gwindow_spawner"

/obj/effect/spawner/window/reinforced
	name = "reinforced window spawner"
	icon_state = "rwindow_spawner"
	window_to_spawn_regular = /obj/structure/window/reinforced
	window_to_spawn_full = /obj/structure/window/full/reinforced

/obj/effect/spawner/window/reinforced/grilled
	name = "grilled reinforced window spawner"
	icon_state = "grwindow_spawner"
	useGrille = TRUE

/obj/effect/spawner/window/plasma
	name = "plasma window spawner"
	icon_state = "pwindow_spawner"
	window_to_spawn_regular = /obj/structure/window/plasmabasic
	window_to_spawn_full = /obj/structure/window/full/plasmabasic

/obj/effect/spawner/window/plasma/grilled
	name = "grilled plasma window spawner"
	icon_state = "gpwindow_spawner"
	useGrille = TRUE

/obj/effect/spawner/window/reinforced/plasma
	name = "reinforced plasma window spawner"
	icon_state = "prwindow_spawner"
	window_to_spawn_regular = /obj/structure/window/plasmareinforced
	window_to_spawn_full = /obj/structure/window/full/plasmareinforced

/obj/effect/spawner/window/reinforced/plasma/grilled
	name = "grilled reinforced plasma window spawner"
	icon_state = "gprwindow_spawner"
	useGrille = TRUE

/obj/effect/spawner/window/reinforced/tinted
	name = "tinted reinforced window spawner"
	icon_state = "twindow_spawner"
	window_to_spawn_regular = /obj/structure/window/reinforced/tinted
	window_to_spawn_full = /obj/structure/window/full/reinforced/tinted

/obj/effect/spawner/window/reinforced/tinted/grilled
	name = "grilled tinted reinforced window spawner"
	icon_state = "gtwindow_spawner"
	useGrille = TRUE

/obj/effect/spawner/window/reinforced/polarized
	name = "electrochromic reinforced window spawner"
	icon_state = "ewindow_spawner"
	window_to_spawn_regular = /obj/structure/window/reinforced/polarized
	window_to_spawn_full = /obj/structure/window/full/reinforced/polarized
	/// Used to link electrochromic windows to buttons
	var/id

/obj/effect/spawner/window/reinforced/polarized/synchronize_variables(atom/a)
	if(useFull)
		var/obj/structure/window/full/reinforced/polarized/p = a
		p.id = id
	else
		var/obj/structure/window/reinforced/polarized/p = a
		p.id = id

/obj/effect/spawner/window/reinforced/polarized/grilled
	name = "grilled electrochromic reinforced window spawner"
	icon_state = "gewindow_spawner"
	useGrille = TRUE

/obj/effect/spawner/window/shuttle
	name = "shuttle window spawner"
	icon_state = "swindow_spawner"
	window_to_spawn_full = /obj/structure/window/full/shuttle
	useGrille = TRUE

/obj/effect/spawner/window/shuttle/survival_pod
	name = "pod window spawner"
	icon_state = "podwindow_spawner"
	window_to_spawn_full = /obj/structure/window/full/shuttle/survival_pod

/obj/effect/spawner/window/shuttle/survival_pod/tinted
	name = "tinted pod window spawner"
	window_to_spawn_full = /obj/structure/window/full/shuttle/survival_pod/tinted

/obj/effect/spawner/window/plastitanium
	name = "plastitanium window spawner"
	icon_state = "plastitaniumwindow_spawner"
	window_to_spawn_full = /obj/structure/window/full/plastitanium
	useGrille = TRUE

/obj/effect/spawner/window/plastitanium/rad_protect
	name = "leaded plastitanium window spawner"
	icon_state = "leaded_plastitaniumwindow_spawner"
	window_to_spawn_full = /obj/structure/window/full/plastitanium/rad_protect
