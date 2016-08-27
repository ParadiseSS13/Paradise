/datum/space_level
	var/name = "Your config settings failed, you need to fix this for the datum space levels to work"
	var/zpos = 1
	var/flags = list() // We'll use this to keep track of whether you can teleport/etc

	// Map transition stuff
	var/list/neighbors = list()
	// # How this level connects with others. See __MAP_DEFINES.dm for defines
	// It's UNAFFECTED by default because none of the space turfs are normally linked up
	// so we don't need to rebuild transitions if an UNAFFECTED level is requested
	var/linkage = UNAFFECTED
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

/datum/space_level/New(z, name, transition_type = SELFLOOPING, traits = list(BLOCK_TELEPORT))
	zpos = z
	flags = traits
	build_space_destination_arrays()
	set_linkage(transition_type)

/datum/space_level/Destroy()
	if(linkage == CROSSLINKED)
		if(space_manager.linkage_map)
			remove_from_space_network(space_manager.linkage_map)

	space_manager.unbuilt_space_transitions -= src
	space_manager.z_list -= "[zpos]"
	return ..()

/datum/space_level/proc/build_space_destination_arrays()
	// We skip `add_to_transit` here because we want to skip the checks in order to save time
	// Bottom border
	for(var/turf/space/S in block(locate(1,1,zpos),locate(world.maxx,TRANSITION_BORDER_SOUTH,zpos)))
		transit_south |= S

	// Top border
	for(var/turf/space/S in block(locate(1,world.maxy,zpos),locate(world.maxx,TRANSITION_BORDER_NORTH,zpos)))
		transit_north |= S

	// Left border
	for(var/turf/space/S in block(locate(1,TRANSITION_BORDER_SOUTH + 1,zpos),locate(TRANSITION_BORDER_WEST,TRANSITION_BORDER_NORTH - 1,zpos)))
		transit_west |= S

	// Right border
	for(var/turf/space/S in block(locate(TRANSITION_BORDER_EAST,TRANSITION_BORDER_SOUTH + 1,zpos),locate(world.maxx,TRANSITION_BORDER_NORTH - 1,zpos)))
		transit_east |= S

/datum/space_level/proc/add_to_transit(turf/space/S)
	if(S.y <= TRANSITION_BORDER_SOUTH)
		transit_south |= S
		return

	// Top border
	if(S.y >= TRANSITION_BORDER_NORTH)
		transit_north |= S
		return

	// Left border
	if(S.x <= TRANSITION_BORDER_WEST)
		transit_west |= S
		return

	// Right border
	if(S.x >= TRANSITION_BORDER_EAST)
		transit_east |= S

/datum/space_level/proc/remove_from_transit(turf/space/S)
	if(S.y <= TRANSITION_BORDER_SOUTH)
		transit_south -= S
		return

	// Top border
	if(S.y >= TRANSITION_BORDER_NORTH)
		transit_north -= S
		return

	// Left border
	if(S.x <= TRANSITION_BORDER_WEST)
		transit_west -= S
		return

	// Right border
	if(S.x >= TRANSITION_BORDER_EAST)
		transit_east -= S

/datum/space_level/proc/apply_transition(turf/space/S)
	if(src in space_manager.unbuilt_space_transitions)
		return // Let the space manager handle this one
	switch(linkage)
		if(UNAFFECTED)
			S.remove_transitions()
		if(SELFLOOPING,CROSSLINKED)
			var/datum/space_level/E = get_connection()
			if(S in transit_north)
				E = get_connection(Z_LEVEL_NORTH)
				S.set_transition_north(E.zpos)
			if(S in transit_south)
				E = get_connection(Z_LEVEL_SOUTH)
				S.set_transition_south(E.zpos)
			if(S in transit_east)
				E = get_connection(Z_LEVEL_EAST)
				S.set_transition_east(E.zpos)
			if(S in transit_west)
				E = get_connection(Z_LEVEL_WEST)
				S.set_transition_west(E.zpos)


/datum/space_level/proc/get_turfs()
	return block(locate(1, 1, zpos), locate(world.maxx, world.maxy, zpos))

/datum/space_level/proc/set_linkage(transition_type)
	if(linkage == transition_type)
		return
	// Remove ourselves from the linkage map if we were cross-linked
	if(linkage == CROSSLINKED)
		if(space_manager.linkage_map)
			remove_from_space_network(space_manager.linkage_map)

	space_manager.unbuilt_space_transitions |= src
	linkage = transition_type
	switch(transition_type)
		if(UNAFFECTED)
			reset_connections()
		if(SELFLOOPING)
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
