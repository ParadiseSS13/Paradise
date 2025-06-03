/**
  * Check to ensure that APCs have a cable node on their tile.
  */
/datum/map_per_tile_test/apc_cable_node_checker

/datum/map_per_tile_test/apc_cable_node_checker/CheckTile(turf/T)
	var/missing_node = TRUE
	var/obj/machinery/power/apc/apc = locate(/obj/machinery/power/apc) in T.contents
	if(apc)
		for(var/obj/structure/cable/cable in T.contents)
			if(cable.d1 == 0 || cable.d2 == 0)
				missing_node = FALSE

		if(missing_node)
			Fail(T, "tile has an APC bump but no center cable node")

/**
  * Check to ensure pipe trunks exist under disposals devices.
  */
/datum/map_per_tile_test/disposal_with_trunk_checker

/datum/map_per_tile_test/disposal_with_trunk_checker/CheckTile(turf/T)
	var/obj/machinery/disposal/disposal = locate(/obj/machinery/disposal) in T.contents
	if(disposal)
		if(!locate(/obj/structure/disposalpipe/trunk) in T.contents)
			Fail(T, "tile has disposal unit/chute but no pipe trunk")

/**
  * Check that only one cable node exists on a tile.
  */
/datum/map_per_tile_test/cable_node_checker

/datum/map_per_tile_test/cable_node_checker/CheckTile(turf/T)
	var/center_nodes = 0

	for(var/obj/structure/cable/cable in T.contents)
		if(cable.d1 == 0 || cable.d2 == 0)
			center_nodes++

	if(center_nodes > 1)
		Fail(T, "tile has multiple center cable nodes")

/datum/map_per_tile_test/nearspace_checker
	var/allowed_turfs = list(/turf/space,
		/turf/simulated/floor/plating/airless,
		/turf/simulated/floor/plasteel/airless,
		/turf/simulated/wall
	)

/datum/map_per_tile_test/nearspace_checker/New()
	..()
	allowed_turfs = typecacheof(allowed_turfs)

/datum/map_per_tile_test/nearspace_checker/CheckTile(turf/T)
	if(T.loc.type == /area/space/nearstation && !is_type_in_list(T, allowed_turfs))
		Fail(T, "nearspace area contains a non-space turf: [T], ([T.type])")


/datum/map_per_tile_test/cable_adjacency_checker

/datum/map_per_tile_test/cable_adjacency_checker/CheckTile(turf/T)
	for(var/obj/structure/cable/cable in T.contents)
		check_direction(T, cable.d1, "d1")
		check_direction(T, cable.d2, "d2")

/datum/map_per_tile_test/cable_adjacency_checker/proc/check_direction(origin_turf, direction, report_name)
	if(!direction) // cable direction = 0, which means its a node
		return TRUE
	var/turf/potential_cable_turf = get_step(origin_turf, direction)
	var/reversed_direction = REVERSE_DIR(direction)
	for(var/obj/structure/cable/other_cable in potential_cable_turf.contents)
		if(reversed_direction == other_cable.d1 || reversed_direction == other_cable.d2)
			return TRUE

	Fail(origin_turf, "tile has an unconnected cable ([report_name] connection: [uppertext(dir2text(direction))]).")
	return FALSE

/datum/map_per_tile_test/missing_pipe_connection

/datum/map_per_tile_test/missing_pipe_connection/CheckTile(turf/T)
	var/obj/machinery/atmospherics/pipe/simple/pipe = locate() in T.contents
	if(isnull(pipe))
		return
	if(!pipe.node1 && !pipe.node2)
		Fail(T, "[pipe] ([pipe.type]) missing both nodes.")
		return
	if(istype(pipe, /obj/machinery/atmospherics/pipe/simple/heat_exchanging) && (pipe.node1 || pipe.node2))
		return // H/E pipes only need one end, because they don't always become full loops
	if(!pipe.node1)
		Fail(T, "[pipe] ([pipe.type]) missing node1. ([uppertext(dir2text(pipe.initialize_directions & ~(get_dir(pipe, pipe.node2))))])")
	if(!pipe.node2)
		Fail(T, "[pipe] ([pipe.type]) missing node2. ([uppertext(dir2text(pipe.initialize_directions & ~(get_dir(pipe, pipe.node1))))])")

/datum/map_per_tile_test/unary_device_connection

/datum/map_per_tile_test/unary_device_connection/CheckTile(turf/T)
	var/obj/machinery/atmospherics/unary/unary_device = locate() in T.contents
	if(isnull(unary_device))
		return
	if(!unary_device.node)
		Fail(T, "[unary_device] ([unary_device.type]) missing node. ([uppertext(dir2text(unary_device.dir))])")
