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
	var/transition_tag
	// # imaginary placements on the grid - these reflect the point it is linked to
	var/xi
	var/yi
	var/list/transit_north = list()
	var/list/transit_south = list()
	var/list/transit_east = list()
	var/list/transit_west = list()

	var/transition_border_north
	var/transition_border_east
	var/transition_border_south
	var/transition_border_west

	// Init deferral stuff
	var/dirt_count = 0
	var/list/init_list = list()

	/// This is a list of ruins on the space_level. Used to prevent certain ruins from spawning on the same level as other ruins.
	var/list/our_ruin_list = list()

/datum/space_level/New(z, level_name, transition_type = SELFLOOPING, traits = list(BLOCK_TELEPORT), transition_tag_)
	name = level_name
	zpos = z
	flags = traits
	transition_tag = transition_tag_

	set_transition_borders()
	build_space_destination_arrays()
	set_linkage(transition_type)
	set_navbeacon()

/datum/space_level/proc/set_transition_borders()
	// can't set these in declaration because world.maxx/y are null for some reason
	transition_border_north = TRANSITION_BORDER_NORTH
	transition_border_east = TRANSITION_BORDER_EAST
	transition_border_south = TRANSITION_BORDER_SOUTH
	transition_border_west = TRANSITION_BORDER_WEST

/datum/space_level/Destroy()
	if(linkage == CROSSLINKED)
		if(GLOB.space_manager.linkage_maps[transition_tag])
			remove_from_space_network(GLOB.space_manager.linkage_maps[transition_tag])

	GLOB.space_manager.unbuilt_space_transitions -= src
	GLOB.space_manager.z_list -= "[zpos]"
	return ..()

/datum/space_level/proc/build_space_destination_arrays()
	// We skip `add_to_transit` here because we want to skip the checks in order to save time
	// Bottom border
	for(var/turf/S in block(locate(1,1,zpos),locate(world.maxx,transition_border_south,zpos)))
		transit_south |= S

	// Top border
	for(var/turf/S in block(locate(1,world.maxy,zpos),locate(world.maxx,transition_border_north,zpos)))
		transit_north |= S

	// Left border
	for(var/turf/S in block(locate(1, transition_border_south + 1, zpos), locate(transition_border_west, transition_border_north - 1, zpos)))
		transit_west |= S

	// Right border
	for(var/turf/S in block(locate(transition_border_east, transition_border_south + 1, zpos),locate(world.maxx, transition_border_north - 1, zpos)))
		transit_east |= S

/datum/space_level/proc/add_to_transit(turf/S)
	if(S.y <= transition_border_south)
		transit_south |= S
		return

	// Top border
	if(S.y >= transition_border_north)
		transit_north |= S
		return

	// Left border
	if(S.x <= transition_border_west)
		transit_west |= S
		return

	// Right border
	if(S.x >= transition_border_east)
		transit_east |= S

/datum/space_level/proc/remove_from_transit(turf/S)
	if(S.y <= transition_border_south)
		transit_south -= S
		return

	// Top border
	if(S.y >= transition_border_north)
		transit_north -= S
		return

	// Left border
	if(S.x <= transition_border_west)
		transit_west -= S
		return

	// Right border
	if(S.x >= transition_border_east)
		transit_east -= S

/datum/space_level/proc/apply_transition(turf/S)
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
	return block(1, 1, zpos, world.maxx, world.maxy, zpos)

/datum/space_level/proc/set_linkage(transition_type)
	if(linkage == transition_type)
		return
	// Remove ourselves from the linkage map if we were cross-linked
	if(linkage == CROSSLINKED)
		if(GLOB.space_manager.linkage_maps[transition_tag])
			remove_from_space_network(GLOB.space_manager.linkage_maps[transition_tag])

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

/datum/space_level/proc/resume_init()
	if(dirt_count > 0)
		throw EXCEPTION("Init told to resume when z-level still dirty. Z level: '[zpos]'")
	var/list/our_atoms = init_list // OURS NOW!!! (Keeping this list to ourselves will prevent hijack)
	init_list = list()
	listclearnulls(our_atoms)
	var/list/pipes = typecache_filter_list(our_atoms, GLOB.atmos_machine_typecache)
	var/list/cables = typecache_filter_list(our_atoms, GLOB.cable_typecache)
	SSatoms.InitializeAtoms(our_atoms, FALSE)
	our_atoms.Cut()
	if(length(pipes))
		do_pipes(pipes)
	if(length(cables))
		do_cables(cables)

/datum/space_level/proc/do_pipes(list/pipes)
	SSair._setup_atmos_machinery(pipes)
	SSair._setup_pipenets(pipes)
	pipes.Cut()

/datum/space_level/proc/do_cables(list/cables)
	SSmachines.setup_template_powernets(cables)
	cables.Cut()

/datum/space_level/proc/has_all_traits(list/traits)
	// Cool, horrible set inclusion
	return length(flags & traits) == length(traits)

/datum/space_level/lavaland/set_transition_borders()
	// really no reason why these need to be so large,
	// especially since ruin placement is already constrained
	transition_border_north = (world.maxy - 4)
	transition_border_east = (world.maxx - 4)
	transition_border_south = 3
	transition_border_west = 3

// space levels have no UI of their own so borrowing this proc for serialization
// for other UIs
/datum/space_level/ui_data(mob/user)
	. = list(
		"name" = name,
		"zpos" = zpos,
		"linkage" = linkage,
		"transition_tag" = transition_tag,
		"traits" = flags,
	)

	.["neighbors"] = list()
	for(var/direction in list(Z_LEVEL_SOUTH, Z_LEVEL_NORTH, Z_LEVEL_EAST, Z_LEVEL_WEST))
		var/datum/space_level/neighbor = get_connection(direction)
		if(neighbor)
			var/dirname = dir2text(text2num(direction))
			.["neighbors"][dirname] = neighbor.zpos

	.["ruins"] = list()
	for(var/obj/effect/landmark/ruin/ruin_landmark in GLOB.ruin_landmarks)
		if(ruin_landmark.z == zpos)
			.["ruins"] += list(list(
				"name" = ruin_landmark.ruin_template.name,
				"mappath" = ruin_landmark.ruin_template.mappath,
				"coords" = list(
					"x" = ruin_landmark.x,
					"y" = ruin_landmark.y,
					"z" = ruin_landmark.z,
				),
			))
