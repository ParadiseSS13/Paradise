/datum/space_level
	var/name = "Your config settings failed, you need to fix this for the datum space levels to work"
	var/zpos = 1
	var/flags = 0 // We'll use this to keep track of whether you can teleport/etc

	// Map transition stuff
	var/list/neighbors = list()
	// # How this level connects with others. See __MAP_DEFINES.dm for defines
	var/linkage = SELFLOOPING
	// # imaginary placements on the grid - these reflect the point it is linked to
	var/xi
	var/yi
	var/list/transit_north = list()
	var/list/transit_south = list()
	var/list/transit_east = list()
	var/list/transit_west = list()

	// Init deferral stuff
	var/dirt_count = 0
	var/list/init_list = list()

/datum/space_level/New(z, name, transition_type = SELFLOOPING)
	zpos = z
	set_linkage(transition_type)
	build_space_destination_arrays()

/datum/space_level/proc/build_space_destination_arrays()
	var/timer = start_watch()
	log_debug("Starting to build space destination arrays for z level '[zpos]'...")
	for(var/turf/space/S in get_turfs())

		// Bottom border
		if(S.y <= TRANSITIONEDGE)
			transit_south |= S
			continue

		// Top border
		if(S.y >= (world.maxy - TRANSITIONEDGE - 1))
			transit_north |= S
			continue

		// Left border
		if(S.x <= TRANSITIONEDGE)
			transit_west |= S
			continue

		// Right border
		if(S.x >= (world.maxx - TRANSITIONEDGE - 1))
			transit_east |= S
			continue
	log_debug("Building space destination arrays complete, took [stop_watch(timer)]s.")

/datum/space_level/proc/get_turfs()
	return block(locate(1, 1, zpos), locate(world.maxx, world.maxy, zpos))

/datum/space_level/proc/set_linkage(transition_type)
	linkage = transition_type
	if(transition_type == SELFLOOPING)
		link_to_self() // `link_to_self` is defined in space_transitions.dm


/datum/space_level/proc/resume_init()
	if(dirt_count > 0)
		throw EXCEPTION("Init told to resume when z-level still dirty. Z level: '[zpos]'")
	log_debug("Releasing freeze on z-level '[zpos]'!")
	log_debug("Beginning initialization!")
	var/list/our_atoms = init_list // OURS NOW!!! (Keeping this list to ourselves will prevent hijack)
	init_list = list()
	var/list/late_maps = list()
	var/list/pipes = list()
	var/list/cables = list()
	var/watch = start_watch()
	for(var/schmoo in our_atoms)
		var/atom/movable/AM = schmoo
		if(AM) // to catch stuff like the nuke disk that no longer exists

			// This can mess with our state - we leave these for last
			if(istype(AM, /obj/effect/landmark/map_loader))
				late_maps.Add(AM)
				continue
			AM.initialize()
			if(istype(AM, /obj/machinery/atmospherics))
				pipes.Add(AM)
			else if(istype(AM, /obj/structure/cable))
				cables.Add(AM)
	log_debug("Primary initialization finished in [stop_watch(watch)]s.")
	our_atoms.Cut()
	if(pipes.len)
		do_pipes(pipes)
	if(cables.len)
		do_cables(cables)
	if(late_maps.len)
		do_late_maps(late_maps)

/datum/space_level/proc/do_pipes(list/pipes)
	var/watch = start_watch()
	log_debug("Building pipenets on z-level '[zpos]'!")
	for(var/schmoo in pipes)
		var/obj/machinery/atmospherics/machine = schmoo
		if(machine)
			machine.build_network()
	pipes.Cut()
	log_debug("Took [stop_watch(watch)]s")

/datum/space_level/proc/do_cables(list/cables)
	var/watch = start_watch()
	log_debug("Building powernets on z-level '[zpos]'!")
	for(var/schmoo in cables)
		var/obj/structure/cable/C = schmoo
		if(C)
			makepowernet_for(C)
	cables.Cut()
	log_debug("Took [stop_watch(watch)]s")

/datum/space_level/proc/do_late_maps(list/late_maps)
	var/watch = start_watch()
	log_debug("Loading map templates on z-level '[zpos]'!")
	space_manager.add_dirt(zpos) // Let's not repeatedly resume init for each template
	for(var/schmoo in late_maps)
		var/obj/effect/landmark/map_loader/ML = schmoo
		if(ML)
			ML.initialize()
	late_maps.Cut()
	space_manager.remove_dirt(zpos)
	log_debug("Took [stop_watch(watch)]s")
