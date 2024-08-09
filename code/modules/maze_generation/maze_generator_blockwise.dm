// Everything in this file is related to the blockwise maze generator.
// It uses some components from the standard, but tweaks them to its own needs, since it needs to generate a half size maze then expand it out

#define MAZEGEN_TURF_UNSEARCHED "#ff0000"
#define MAZEGEN_TURF_CELL "#00ff00"

/obj/effect/mazegen/generator/blockwise
	name = "blockwise maze generator"
	/// Material to make the walls out of
	var/turf/wall_material = /turf/simulated/wall/indestructible/riveted
	/// Material to make the floor out of
	var/turf/floor_material = /turf/simulated/floor/engine
	/// List of open spots (speeds up calculations)
	var/list/turf/open_spots = list()

// First we need to override the main proc so it only calculates half
/obj/effect/mazegen/generator/blockwise/run_generator()
	ASSERT(ISODD(mwidth))
	ASSERT(ISODD(mheight))
	var/total_time = start_watch()
	log_debug("\[MAZE] Started generation on maze at [x],[y],[z] | [mwidth * mheight] turfs total")
	// First we need to partition the maze out into forced walls and open cells
	LOG_MAZE_PROGRESS(generate_path(), "Generate Path")
	LOG_MAZE_PROGRESS(apply_helper_modules(TRUE), "Helper Modules")
	if(length(loot_modules)) // Only bother with this if we have some
		LOG_MAZE_PROGRESS(calculate_loot_spots(), "Loot Spot Calculation")
		LOG_MAZE_PROGRESS(apply_loot_modules(), "Loot Modules")
	log_debug("\[MAZE] Generation of maze at [x],[y],[z] complete within [stop_watch(total_time)]s")
	qdel(src)


/obj/effect/mazegen/generator/blockwise/generate_path()
	// Setup our turf list
	var/width = clamp(mwidth, 0, (world.maxx - x)) // Make sure they dont loop off the world
	var/height = clamp(mheight, 0, (world.maxy - y)) // Make sure they dont loop off the world

	// Generate a turf stack
	for(var/target_x in 0 to (width - 1)) // -1 so it spawns on the right tile
		for(var/target_y in 0 to (height - 1))
			var/turf/T = locate((x + target_x), (y + target_y), z)
			// Mark as unsearched
			T.color = MAZEGEN_TURF_UNSEARCHED
			// Throw it in the list
			turf_list |= T
			CHECK_TICK
		CHECK_TICK

	// Do the actual work
	push_turf(turf_list[1]) // Use the first turf as the stack base
	while(length(working_stack))
		var/turf/T = pop_turf()

		// If you dont force cast these to strings, stuff cries. A lot.
		var/list/cardinals = list("[NORTH]", "[SOUTH]", "[EAST]", "[WEST]")

		// Unvisited turfs
		var/list/turf/unvisited_neighbours = list()

		// Check all cardinal turfs
		for(var/D in cardinals)
			var/turf/T2 = get_step(get_step(T, text2num(D)), text2num(D)) // Get the step TWICE because this is wallwise
			if(T2?.color == MAZEGEN_TURF_UNSEARCHED)
				unvisited_neighbours["[D]"] += T2

		if(length(unvisited_neighbours))
			push_turf(T)
			var/D = pick(unvisited_neighbours)
			var/turf/T3 = unvisited_neighbours["[D]"] // Pick random dir turf

			// Remove the color between the two
			var/turf/T4 = get_step(T3, REVERSE_DIR(text2num(D)))
			T4?.color = MAZEGEN_TURF_CELL

			// Mark as visited
			T3.color = MAZEGEN_TURF_CELL
			push_turf(T3)

		CHECK_TICK

	// The walls have been generated, now cleanup turfs and gather helpers
	for(var/i in turf_list)
		var/turf/T = i
		// Set correct turfs
		if(T.color == MAZEGEN_TURF_CELL)
			open_spots |= T
			T.ChangeTurf(floor_material)
		else
			T.ChangeTurf(wall_material)
		T.color = null

		// Gather loot modules
		for(var/obj/effect/mazegen/module_loot/ML in T)
			loot_modules |= ML
			CHECK_TICK

		// Gather helper modules
		for(var/obj/effect/mazegen/module_helper/MH in T)
			helper_modules |= MH
			CHECK_TICK

		// Make sure we have adequate CPU
		CHECK_TICK

/obj/effect/mazegen/generator/blockwise/calculate_loot_spots()
	for(var/i in open_spots)
		var/turf/T = i
		// Gather amount of dense turfs on each side
		var/dense_surrounding_turfs = 0
		// Again, these gotta be casted like this
		var/list/cardinals = list("[NORTH]", "[EAST]", "[SOUTH]", "[WEST]")
		for(var/D in cardinals)
			var/turf/T2 = get_step(T, text2num(D))
			if(T2.density)
				dense_surrounding_turfs++
			CHECK_TICK

		// Its a dead end. Mark for loot.
		if(dense_surrounding_turfs == 3)
			potential_loot_spots |= T

		CHECK_TICK

#undef MAZEGEN_TURF_UNSEARCHED
#undef MAZEGEN_TURF_CELL
