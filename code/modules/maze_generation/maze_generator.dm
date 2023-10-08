/*
	Everything in this file is related to the actual maze generator itself
	This does the brunt of the work and handles the actual calculations of the mazes

	It is very finnicky code and isnt easy to work with since BYOND doesnt like wallwise mazes, and this would be much better being blockwise

	I dont recommend touching the stuff in here, its very finnicky and can be difficult to get your head around if youre not familiar with maze generation algorithms
	-AA07

*/

// Nice way to format logs
#define LOG_MAZE_PROGRESS(proc2run, opname) \
do { \
	var/timer = start_watch(); \
	proc2run ;\
	log_debug("\[MAZE] Operation '[opname]' on maze at [x],[y],[z] took [stop_watch(timer)]s"); \
} while(FALSE)


// These defines are used to mark the cells as explored or not
#define MAZEGEN_TURF_UNSEARCHED "#ff0000"
#define MAZEGEN_TURF_CELL "#00ff00"

// Dont place this in the very corner of a map. It relies on adjacent turfs, and at the very edges you dont have turfs on all sides
/obj/effect/mazegen/generator
	name = "maze generator"
	/// List of turfs to iterate in total
	var/list/turf_list = list()
	/// "Stack" structure to be used while iterating
	var/list/working_stack = list()
	/// List of all loot modules being used in this maze
	var/list/obj/effect/mazegen/module_loot/loot_modules = list()
	/// List of all helper modules being used in this maze
	var/list/obj/effect/mazegen/module_helper/helper_modules = list()
	/// Potential loot spots
	var/list/turf/potential_loot_spots = list()
	/// Maze width
	var/mwidth = 0
	/// Maze height
	var/mheight = 0

/obj/effect/mazegen/generator/Initialize(mapload)
	. = ..()
	SSlate_mapping.maze_generators += src

/obj/effect/mazegen/generator/Destroy()
	SSlate_mapping.maze_generators -= src
	return ..()

// "Push" a turf to the working "stack"
/obj/effect/mazegen/generator/proc/push_turf(turf/T)
	working_stack.Add(T) // Add it to the end of the list

// "Pop" a turf off the working "stack"
/obj/effect/mazegen/generator/proc/pop_turf()
	var/turf/T = working_stack[length(working_stack)] // Get the last item in the list
	working_stack.Remove(T) // Take it off the top
	return T // Send it back

// Main generator runner. Override on children
/obj/effect/mazegen/generator/proc/run_generator()
	ASSERT(ISODD(mwidth))
	ASSERT(ISODD(mheight))
	var/total_time = start_watch()
	log_debug("\[MAZE] Started generation on maze at [x],[y],[z] | [mwidth * mheight] turfs total")
	LOG_MAZE_PROGRESS(generate_path(), "Path Generation")
	LOG_MAZE_PROGRESS(apply_helper_modules(FALSE), "Helper Modules")
	if(length(loot_modules)) // Only bother with this if we have some
		LOG_MAZE_PROGRESS(calculate_loot_spots(), "Loot Spot Calculation")
		LOG_MAZE_PROGRESS(apply_loot_modules(), "Loot Modules")
	log_debug("\[MAZE] Generation of maze at [x],[y],[z] complete within [stop_watch(total_time)]s")
	qdel(src)

/obj/effect/mazegen/generator/proc/generate_path()
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

			// Windows time
			var/obj/structure/window/reinforced/mazeglass/WN = new(T)
			WN.dir = NORTH
			var/obj/structure/window/reinforced/mazeglass/WS = new(T)
			WS.dir = SOUTH
			var/obj/structure/window/reinforced/mazeglass/WE = new(T)
			WE.dir = EAST
			var/obj/structure/window/reinforced/mazeglass/WW = new(T)
			WW.dir = WEST
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
			var/turf/T2 = get_step(T, text2num(D))
			if(T2.color == MAZEGEN_TURF_UNSEARCHED)
				unvisited_neighbours["[D]"] += T2

		if(length(unvisited_neighbours))
			push_turf(T)
			var/D = pick(unvisited_neighbours)
			var/turf/T3 = unvisited_neighbours["[D]"] // Pick random dir turf

			// Remove the window between the two
			for(var/obj/structure/window/reinforced/mazeglass/W in T)
				if(W.dir == text2num(D))
					qdel(W)

			// On both tiles
			for(var/obj/structure/window/reinforced/mazeglass/W in T3)
				if(W.dir == GetOppositeDir(text2num(D)))
					qdel(W)

			// Mark as visited
			T3.color = MAZEGEN_TURF_CELL
			push_turf(T3)

		CHECK_TICK

	// The walls have been generated, now cleanup turfs and gather helpers
	for(var/i in turf_list)
		var/turf/T = i
		// Reset markings
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

/obj/effect/mazegen/generator/proc/apply_helper_modules(blockwise = FALSE)
	// Apply helpers
	for(var/i in helper_modules)
		var/obj/effect/mazegen/module_helper/MH = i
		helper_modules -= MH // Make it happy
		MH.helper_run(blockwise, src)
		qdel(MH)

/obj/effect/mazegen/generator/proc/calculate_loot_spots()
	for(var/i in turf_list)
		var/turf/T = i
		// Gather the windows. If a spot has 3 windows on it, its a dead end
		var/windowcount = 0
		for(var/obj/structure/window/reinforced/mazeglass/W in T)
			pass(W) // Stops DM whining about unused vars
			windowcount++
			CHECK_TICK

		// Its a dead end. Mark for loot.
		if(windowcount == 3)
			potential_loot_spots |= T

		CHECK_TICK

/obj/effect/mazegen/generator/proc/apply_loot_modules()
	for(var/i in potential_loot_spots)
		var/turf/T = i

		// Apply loot modules
		var/obj/effect/mazegen/module_loot/ML = pick(loot_modules)
		if(prob(ML.spawn_probability))
			ML.spawn_loot(T) // Spawn on the turf

		CHECK_TICK

	// Cleanup loot modules
	for(var/i in loot_modules)
		var/obj/effect/mazegen/module_loot/ML = i
		loot_modules -= ML // Take it out to make the GC happy
		qdel(ML)
		CHECK_TICK


#undef MAZEGEN_TURF_UNSEARCHED
#undef MAZEGEN_TURF_CELL
