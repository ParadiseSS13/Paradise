/datum/map_per_tile_test
	var/succeeded = TRUE
	var/list/fail_reasons

/datum/map_per_tile_test/proc/CheckTile(turf/T)
	Fail("CheckTile() called parent or not implemented")

/datum/map_per_tile_test/proc/Fail(reason = "No reason")
	succeeded = FALSE

	if(!istext(reason))
		reason = "FORMATTED: [reason != null ? reason : "NULL"]"

	LAZYADD(fail_reasons, reason)

/datum/map_per_tile_test/pipe_vent_checker
	var/list/pipe_roots = list(
		/obj/machinery/atmospherics/pipe/manifold/hidden/supply,
		/obj/machinery/atmospherics/pipe/simple/hidden/scrubbers
	)
	var/list/unary_roots = list(
		/obj/machinery/atmospherics/unary
	)

/datum/map_per_tile_test/pipe_vent_checker/CheckTile(turf/T)
	var/turf/t = T
	var/has_pipe = FALSE
	var/has_unary = FALSE

	if(t)
		for(var/pipe_root in pipe_roots)
			if(locate(pipe_root) in t.contents)
				has_pipe = TRUE

		if(locate(/obj/machinery/atmospherics/unary) in t.contents)
			has_unary = TRUE

		if(has_pipe && has_unary)
			succeeded = FALSE
			LAZYADD(fail_reasons, "[t.x],[t.y],[t.z]: pipe on same tile as vent or scrubber")

	else
		succeeded = FALSE
		LAZYADD(fail_reasons, "No turf at [t.x],[t.y],[t.z]!")

/datum/map_per_tile_test/cable_node_checker

/datum/map_per_tile_test/cable_node_checker/CheckTile(turf/T)
	var/turf/t = T
	var/center_nodes = 0

	if(t)
		for(var/obj/structure/cable/cable in t.contents)
			if(cable.d1 == 0 || cable.d2 == 0)
				center_nodes++

		if(center_nodes > 1)
			succeeded = FALSE
			LAZYADD(fail_reasons, "[t.x],[t.y],[t.z]: tile has multiple center cable nodes")

