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

/datum/space_level/New(z, level_name, transition_type = SELFLOOPING, traits = list(BLOCK_TELEPORT))
	name = level_name
	zpos = z
	flags = traits
	build_space_destination_arrays()
	set_linkage(transition_type)
	set_navbeacon()

/datum/space_level/Destroy()
	if(linkage == CROSSLINKED)
		if(GLOB.space_manager.linkage_map)
			remove_from_space_network(GLOB.space_manager.linkage_map)

	GLOB.space_manager.unbuilt_space_transitions -= src
	GLOB.space_manager.z_list -= "[zpos]"
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
	if(src in GLOB.space_manager.unbuilt_space_transitions)
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
		if(GLOB.space_manager.linkage_map)
			remove_from_space_network(GLOB.space_manager.linkage_map)

	GLOB.space_manager.unbuilt_space_transitions |= src
	linkage = transition_type
	switch(transition_type)
		if(UNAFFECTED)
			reset_connections()
		if(SELFLOOPING)
			link_to_self() // `link_to_self` is defined in space_transitions.dm

//create docking ports for navigation consoles to jump to
/datum/space_level/proc/set_navbeacon()
	var/obj/docking_port/stationary/D = new /obj/docking_port/stationary(src)
	D.name = name
	D.id = "nav_z[zpos]"
	D.register()
	D.forceMove(locate(200, 200, zpos))

GLOBAL_LIST_INIT(atmos_machine_typecache, typecacheof(/obj/machinery/atmospherics))
GLOBAL_LIST_INIT(cable_typecache, typecacheof(/obj/structure/cable))
GLOBAL_LIST_INIT(maploader_typecache, typecacheof(/obj/effect/landmark/map_loader))

/datum/space_level/proc/resume_init()
	if(dirt_count > 0)
		throw EXCEPTION("Init told to resume when z-level still dirty. Z level: '[zpos]'")
	log_debug("Releasing freeze on z-level '[zpos]'!")
	log_debug("Beginning initialization!")
	var/list/our_atoms = init_list // OURS NOW!!! (Keeping this list to ourselves will prevent hijack)
	init_list = list()
	var/watch = start_watch()
	listclearnulls(our_atoms)
	var/list/late_maps = typecache_filter_list(our_atoms, GLOB.maploader_typecache)
	var/list/pipes = typecache_filter_list(our_atoms, GLOB.atmos_machine_typecache)
	var/list/cables = typecache_filter_list(our_atoms, GLOB.cable_typecache)
	// If we don't carefully add dirt around the map templates, bad stuff happens
	// so we separate them out here
	our_atoms -= late_maps
	SSatoms.InitializeAtoms(our_atoms, FALSE)
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
	log_debug("Initializing atmos machines on z-level '[zpos]'!")
	var/init_count = SSair._setup_atmos_machinery(pipes)
	log_debug("Initialized [init_count] machines, took [stop_watch(watch)]s")
	watch = start_watch()
	log_debug("Initializing pipe networks on z-level '[zpos]'!")
	init_count = SSair._setup_pipenets(pipes)
	log_debug("Initialized pipenets for [init_count] machines, took [stop_watch(watch)]s")
	pipes.Cut()

/datum/space_level/proc/do_cables(list/cables)
	var/watch = start_watch()
	log_debug("Building powernets on z-level '[zpos]'!")
	SSmachines.setup_template_powernets(cables)
	cables.Cut()
	log_debug("Took [stop_watch(watch)]s")

/datum/space_level/proc/do_late_maps(list/late_maps)
	var/watch = start_watch()
	log_debug("Loading map templates on z-level '[zpos]'!")
	GLOB.space_manager.add_dirt(zpos) // Let's not repeatedly resume init for each template
	for(var/atom/movable/AM in late_maps)
		AM.Initialize()
	late_maps.Cut()
	GLOB.space_manager.remove_dirt(zpos)
	log_debug("Took [stop_watch(watch)]s")
