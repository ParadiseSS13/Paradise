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
	/// List of all bridge spawners to process
	var/list/obj/effect/spawner/bridge/bridge_spawners = list()

/datum/controller/subsystem/late_mapping/Initialize()
	// Sort all the air machines we initialized during mapload by name all at once
	GLOB.air_alarms = sortAtom(GLOB.air_alarms)
	GLOB.apcs = sortAtom(GLOB.apcs)

	if(length(maze_generators))
		var/watch = start_watch()
		log_startup_progress("Generating mazes...")

		for(var/i in maze_generators)
			var/obj/effect/mazegen/generator/MG = i
			MG.run_generator()

		var/list/mgcount = length(maze_generators) // Keeping track of this here because we wipe it next line down
		QDEL_LIST_CONTENTS(maze_generators)
		var/duration = stop_watch(watch)
		log_startup_progress("Generated [mgcount] mazes in [duration]s")

	if(length(bridge_spawners))
		var/watch = start_watch()
		log_startup_progress("Spawning bridges...")

		for(var/i in bridge_spawners)
			var/obj/effect/spawner/bridge/BS = i
			BS.generate_bridge()

		var/list/bscount = length(bridge_spawners) // Keeping track of this here because we wipe it next line down
		QDEL_LIST_CONTENTS(bridge_spawners)
		var/duration = stop_watch(watch)
		log_startup_progress("Spawned [bscount] bridges in [duration]s")
