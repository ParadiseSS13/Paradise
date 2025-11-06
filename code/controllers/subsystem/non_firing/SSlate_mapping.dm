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

/datum/controller/subsystem/late_mapping/Initialize()
	// Sort all the air machines we initialized during mapload by name all at once
	GLOB.air_alarms = sortAtom(GLOB.air_alarms)
	GLOB.apcs = sortAtom(GLOB.apcs)

	for(var/obj/machinery/computer/shuttle/console in SSmachines.get_by_type(/obj/machinery/computer/shuttle))
		if(console.find_destinations_in_late_mapping)
			console.connect()

	// Use whether we have any interior door UIDs as a proxy
	// to determine if we haven't been linked yet
	var/list/controllers = SSmachines.get_by_type(/obj/machinery/airlock_controller)
	for(var/obj/machinery/airlock_controller/controller as anything in controllers)
		if(!length(controller.interior_doors))
			controller.link_all_items()

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

	maintenance_mice()

	GLOB.spawn_pool_manager.process_pools()

/**
 * Randomly spawns mice in maintenance instead of being purely fixed spawn points
 */
/datum/controller/subsystem/late_mapping/proc/maintenance_mice()
	var/watch = start_watch()
	log_startup_progress("Populating maintenance with mice...")

	// Looking up for maintenance floors specifically as possible spawn points
	var/list/maintenance_turfs = list()
	for(var/area/station/maintenance/A in SSmapping.existing_station_areas)
		for(var/turf/simulated/floor/F in A)
			if(locate(/obj/structure/window) in F)
				continue
			maintenance_turfs.Add(F)

	if(!length(maintenance_turfs))
		log_debug("No valid turfs has been found for mice.")
		return

	// The ratio is based on turfs per mice. Using Boxstation as an example, it would average between 20 to 30 mice.
	var/floor_tiles_per_one_mice = rand(125, 200)
	var/mice_number = ceil(length(maintenance_turfs) / floor_tiles_per_one_mice)

	for(var/i in 1 to mice_number)
		if(prob(1))
			new /mob/living/basic/mouse/white/linter(pick_n_take(maintenance_turfs))
		else
			new /mob/living/basic/mouse(pick_n_take(maintenance_turfs))

	log_debug("Spawned [mice_number] mice over in [stop_watch(watch)]s")
