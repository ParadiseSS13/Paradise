// This subsystem is to initialize things which need to happen after SSatoms
// This is for things which can take a long period of time and shouldnt bog down SSatoms
// Use this for stuff like random room spawners or maze generators
// Basically, this manages atom-based maploaders
SUBSYSTEM_DEF(late_mapping)
	name = "Late Mapping"
	init_order = INIT_ORDER_LATE_MAPPING
	flags = SS_NO_FIRE
	/// List of all maze generators to process
	var/list/obj/effect/mazegen/generator/maze_generators = list()

/datum/controller/subsystem/late_mapping/Initialize(start_timeofday)
	if(length(maze_generators))
		log_startup_progress("Generating mazes...")
		for(var/i in maze_generators)
			var/obj/effect/mazegen/generator/MG = i
			MG.run_generator()
	return ..()
