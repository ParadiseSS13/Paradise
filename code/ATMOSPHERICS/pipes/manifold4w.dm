/obj/machinery/atmospherics/pipe/manifold4w
	icon = 'icons/atmos/manifold.dmi'
	icon_state = ""
	name = "4-way pipe manifold"
	desc = "A manifold composed of regular pipes"

	volume = 140

	dir = SOUTH
	initialize_directions = NORTH|SOUTH|EAST|WEST

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3
	var/obj/machinery/atmospherics/node4

	level = 1

/obj/machinery/atmospherics/pipe/manifold4w/New()
	..()
	alpha = 255
	icon = null

/obj/machinery/atmospherics/pipe/manifold4w/pipeline_expansion()
	return list(node1, node2, node3, node4)

/obj/machinery/atmospherics/pipe/manifold4w/process_atmos()
	if(!parent)
		..()
	else
		. = PROCESS_KILL

/obj/machinery/atmospherics/pipe/manifold4w/Destroy()
	. = ..()

	if(node1)
		node1.disconnect(src)
		node1.defer_build_network()
		node1 = null
	if(node2)
		node2.disconnect(src)
		node2.defer_build_network()
		node2 = null
	if(node3)
		node3.disconnect(src)
		node3.defer_build_network()
		node3 = null
	if(node4)
		node4.disconnect(src)
		node4.defer_build_network()
		node4 = null

/obj/machinery/atmospherics/pipe/manifold4w/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node2 = null

	if(reference == node3)
		if(istype(node3, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node3 = null

	if(reference == node4)
		if(istype(node4, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node4 = null

	check_nodes_exist()
	update_icon()

	..()

/obj/machinery/atmospherics/pipe/manifold4w/change_color(var/new_color)
	..()
	//for updating connected atmos device pipes (i.e. vents, manifolds, etc)
	if(node1)
		node1.update_underlays()
	if(node2)
		node2.update_underlays()
	if(node3)
		node3.update_underlays()
	if(node4)
		node4.update_underlays()

/obj/machinery/atmospherics/pipe/manifold4w/update_icon(var/safety = 0)
	..()

	if(!check_icon_cache())
		return

	alpha = 255
	overlays.Cut()
	overlays += GLOB.pipe_icon_manager.get_atmos_icon("manifold", , pipe_color, "4way" + icon_connect_type)
	overlays += GLOB.pipe_icon_manager.get_atmos_icon("manifold", , , "clamps_4way" + icon_connect_type)
	underlays.Cut()

	var/turf/T = get_turf(src)
	if(!istype(T)) return
	var/list/directions = list(NORTH, SOUTH, EAST, WEST)
	var/node1_direction = get_dir(src, node1)
	var/node2_direction = get_dir(src, node2)
	var/node3_direction = get_dir(src, node3)
	var/node4_direction = get_dir(src, node4)

	directions -= dir

	directions -= add_underlay(T,node1,node1_direction,icon_connect_type)
	directions -= add_underlay(T,node2,node2_direction,icon_connect_type)
	directions -= add_underlay(T,node3,node3_direction,icon_connect_type)
	directions -= add_underlay(T,node4,node4_direction,icon_connect_type)

	for(var/D in directions)
		add_underlay(T,,D,icon_connect_type)

/obj/machinery/atmospherics/pipe/manifold4w/update_underlays()
	..()
	update_icon()


// A check to make sure both nodes exist - self-delete if they aren't present
/obj/machinery/atmospherics/pipe/manifold4w/check_nodes_exist()
	if(!node1 && !node2 && !node3 && !node4)
		deconstruct()
		return 0 // 0: No nodes exist
	// 1: 1-4 nodes exist, we continue existing
	return 1

/obj/machinery/atmospherics/pipe/manifold4w/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0

/obj/machinery/atmospherics/pipe/manifold4w/atmos_init()
	..()
	for(var/D in GLOB.cardinal)
		for(var/obj/machinery/atmospherics/target in get_step(src, D))
			if(target.initialize_directions & get_dir(target,src))
				var/c = check_connect_types(target,src)
				if(!c)
					continue
				if(D == NORTH)
					target.connected_to = c
					connected_to = c
					node1 = target
				else if(D == SOUTH)
					target.connected_to = c
					connected_to = c
					node2 = target
				else if(D == EAST)
					target.connected_to = c
					connected_to = c
					node3 = target
				else if(D == WEST)
					target.connected_to = c
					connected_to = c
					node4 = target
				break

	var/turf/T = src.loc			// hide if turf is not intact
	hide(T.intact)
	update_icon()

/obj/machinery/atmospherics/pipe/manifold4w/visible
	icon_state = "map_4way"
	level = 2

/obj/machinery/atmospherics/pipe/manifold4w/visible/scrubbers
	name="4-way scrubbers pipe manifold"
	desc = "A manifold composed of scrubbers pipes"
	icon_state = "map_4way-scrubbers"
	connect_types = list(3)
	layer = 2.38
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/manifold4w/visible/supply
	name="4-way air supply pipe manifold"
	desc = "A manifold composed of supply pipes"
	icon_state = "map_4way-supply"
	connect_types = list(2)
	layer = 2.39
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/manifold4w/visible/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/manifold4w/visible/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/manifold4w/visible/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/manifold4w/visible/purple
	color = PIPE_COLOR_PURPLE

/obj/machinery/atmospherics/pipe/manifold4w/hidden
	icon_state = "map_4way"
	level = 1
	alpha = 128		//set for the benefit of mapping - this is reset to opaque when the pipe is spawned in game

/obj/machinery/atmospherics/pipe/manifold4w/hidden/scrubbers
	name="4-way scrubbers pipe manifold"
	desc = "A manifold composed of scrubbers pipes"
	icon_state = "map_4way-scrubbers"
	connect_types = list(3)
	layer = 2.38
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/manifold4w/hidden/supply
	name="4-way air supply pipe manifold"
	desc = "A manifold composed of supply pipes"
	icon_state = "map_4way-supply"
	connect_types = list(2)
	layer = 2.39
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/manifold4w/hidden/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/manifold4w/hidden/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/manifold4w/hidden/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/manifold4w/hidden/purple
	color = PIPE_COLOR_PURPLE
