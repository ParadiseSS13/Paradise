/datum/map_per_tile_test
	var/succeeded = TRUE
	var/list/fail_reasons

/datum/map_per_tile_test/proc/CheckTile(turf/T)
	Fail("CheckTile() called parent or not implemented")

/datum/map_per_tile_test/proc/Fail(turf/T, reason)
	succeeded = FALSE
	LAZYADD(fail_reasons, "[T.x],[T.y],[T.z]: [reason]")

/datum/map_per_tile_test/pipe_vent_checker
	var/list/pipe_roots = list(
		/obj/machinery/atmospherics/pipe/manifold/hidden/supply,
		/obj/machinery/atmospherics/pipe/simple/hidden/scrubbers
	)
	var/list/unary_roots = list(
		/obj/machinery/atmospherics/unary
	)

/datum/map_per_tile_test/pipe_vent_checker/CheckTile(turf/T)
	var/has_pipe = FALSE
	var/has_unary = FALSE

	for(var/pipe_root in pipe_roots)
		if(locate(pipe_root) in T.contents)
			has_pipe = TRUE

	if(locate(/obj/machinery/atmospherics/unary) in T.contents)
		has_unary = TRUE

	if(has_pipe && has_unary)
		Fail(T, "pipe on same tile as vent or scrubber")

/datum/map_per_tile_test/cable_node_checker

/datum/map_per_tile_test/cable_node_checker/CheckTile(turf/T)
	var/center_nodes = 0

	for(var/obj/structure/cable/cable in T.contents)
		if(cable.d1 == 0 || cable.d2 == 0)
			center_nodes++

	if(center_nodes > 1)
		Fail(T, "tile has multiple center cable nodes")

