//This is realisation of the working torus-looping randomized-per-round space map, this kills the cube


/proc/get_opposite_direction(direction)
	switch(direction)
		if(Z_LEVEL_NORTH)
			return Z_LEVEL_SOUTH
		if(Z_LEVEL_SOUTH)
			return Z_LEVEL_NORTH
		if(Z_LEVEL_EAST)
			return Z_LEVEL_WEST
		if(Z_LEVEL_WEST)
			return Z_LEVEL_EAST


// Do this before setting up new connections, or the old ones will haunt you
/datum/space_level/proc/reset_connections()
	neighbors.Cut()

/datum/space_level/proc/link_to_self()
	reset_connections()
	neighbors = list()
	var/list/L = list(Z_LEVEL_NORTH,Z_LEVEL_SOUTH,Z_LEVEL_EAST,Z_LEVEL_WEST)
	for(var/A in L)
		neighbors[A] = src

// Only call this when the `linkage_map` is already built
/datum/space_level/proc/add_to_space_network(datum/spacewalk_grid/SW)
	// Make sure we don't bring any noise data into the network
	reset_connections()
	xi = initial(xi)
	yi = initial(yi)
	var/datum/point/P = SW.get_empty_node()
	P.set_space_level(src)

/datum/space_level/proc/remove_from_space_network(datum/spacewalk_grid/SW)
	var/datum/point/P = SW.get(xi,yi)
	SW.release_node(P)
	// Only do this when we're done, or we'll trample vars needed for releasing
	// the level
	xi = initial(xi)
	yi = initial(yi)
	reset_connections()

// This proc takes another space level, and establishes a connection between the
// two depending on how the `xi` and the `yi` values compare
/datum/space_level/proc/link_levels(datum/space_level/S)
	if(S.xi == xi)
		if(S.yi == yi+1)
			add_connection(S, Z_LEVEL_NORTH)
		else if(S.yi == yi-1)
			add_connection(S, Z_LEVEL_SOUTH)
	else if(S.yi == yi)
		if(S.xi == xi+1)
			add_connection(S, Z_LEVEL_EAST)
		else if(S.xi == xi-1)
			add_connection(S, Z_LEVEL_WEST)
	else // yell about evil wizards, this shouldn't happen
		log_debug("Two z levels attempted to link, but were not adjacent! Our z:([xi],[yi]). Other z:([S.xi],[S.yi])")

// `direction` here is the direction from `src` to `S`
/datum/space_level/proc/add_connection(datum/space_level/S, direction)
	var/oppose = get_opposite_direction(direction)
	neighbors[direction] = S
	S.neighbors[oppose] = src
	space_manager.unbuilt_space_transitions |= src
	space_manager.unbuilt_space_transitions |= S


/datum/space_level/proc/get_connection(direction)
	if(direction in neighbors)
		return neighbors[direction]

	// It's in a direction that loops - so we step as far in the opposite direction to get where to wrap to
	var/datum/space_level/S = src
	var/oppose = get_opposite_direction(direction)
	// Loop all the way in the other direction that we can
	while(S.neighbors[oppose])
		if(S.neighbors[oppose] == src) // we've got a tesseract, boys
			CRASH("Tesseract formed when routing connections between z levels. Culprit: z level '[S.zpos]' to '[src.zpos]', direction [oppose]")
		S = S.neighbors[oppose]
	return S


/datum/point					//this is explicitly utilitarian datum type made specially for the space map generation and are absolutely unusable for anything else
	var/list/neighbors = list()
	var/x
	var/y
	var/datum/space_level/spl

/datum/point/New(nx, ny)
	x = nx
	y = ny

/datum/point/proc/hash()
	return "([x],[y])"

// This is called only on `filled_nodes` - meaning we have a guarantee that
// it is already surrounded on all sides
/datum/point/proc/set_neighbors(datum/spacewalk_grid/SW)
	neighbors.Cut()
	neighbors |= SW.get(x+1, y, allow_empty = 1)
	neighbors |= SW.get(x-1, y, allow_empty = 1)
	neighbors |= SW.get(x, y+1, allow_empty = 1)
	neighbors |= SW.get(x, y-1, allow_empty = 1)

// Updates variables of the space level
/datum/point/proc/set_space_level(datum/space_level/S)
	spl = S
	S.xi = x
	S.yi = y
	for(var/datum/point/P in neighbors)
		if(istype(P.spl))
			// Since each time this proc is called, it is the first time
			// that the z level is added to the grid, we know for certain
			// that no other z level has this as its neighbor
			spl.link_levels(P.spl)

// Returns a list of all neighbors that don't have a space level yet
// If a node doesn't exist yet, it will create it
// This is only called for nodes within the `available_nodes` list
/datum/point/proc/get_empty_neighbors(datum/spacewalk_grid/SW)
	var/list/result
	var/datum/point/up = SW.get(x, y+1, allow_empty = 1)
	var/datum/point/down = SW.get(x, y-1, allow_empty = 1)
	var/datum/point/left = SW.get(x-1, y, allow_empty = 1)
	var/datum/point/right = SW.get(x+1, y, allow_empty = 1)
	if(isnull(up))
		up = new(x, y+1)
		SW.add_available_node(up)

	if(isnull(down))
		down = new(x, y-1)
		SW.add_available_node(down)

	if(isnull(left))
		left = new(x-1, y)
		SW.add_available_node(left)

	if(isnull(right))
		right = new(x+1, y)
		SW.add_available_node(right)

	// Nodes with a space datum are not empty
	result = list(up, down, left, right)
	for(var/datum/point/thing in result)
		if(!isnull(thing.spl))
			result -= thing
	return result

// This looks around itself to see if it has any active nodes within the cardinal directions
/datum/point/proc/has_no_neighbors(datum/spacewalk_grid/SW)
	var/result = 1
	if(!isnull(SW.get(x+1,y)))
		result = 0
	if(!isnull(SW.get(x-1,y)))
		result = 0
	if(!isnull(SW.get(x,y+1)))
		result = 0
	if(!isnull(SW.get(x,y-1)))
		result = 0
	return result


/datum/point/proc/deactivate()
	if(!spl)
		throw EXCEPTION("Attempted to deactivate inactive point")
	for(var/direction in spl.neighbors)
		var/datum/space_level/S = spl.neighbors[direction]
		var/oppose = get_opposite_direction(direction)
		S.neighbors.Remove(oppose)
		space_manager.unbuilt_space_transitions |= S
	spl.reset_connections()
	spl = initial(spl)

// This is like the old algorithm, except this one
// can expand indefinitely and add new points on the fly

// The algorithm is: Start in the center, and add all adjacent points to a list of things to select
// Then repeatedly do the cycle of choosing a node next to any previously-selected node, then
// add all points next to your chosen node to the list of things to select
/datum/spacewalk_grid
	// This is a list of fully initialized nodes - these have their neighbors
	// assigned, and are surrounded
	var/list/filled_nodes = list()
	// These nodes are not fully initialized - their neighbors field is empty,
	// and they do not correspond to a space level
	var/list/available_nodes = list()
	var/list/all_nodes = list() // filled_nodes | available_nodes
	var/min_x = 0
	var/min_y = 0
	var/max_x = 0
	var/max_y = 0

/datum/spacewalk_grid/New()
	var/datum/point/P = new(0,0)
	add_available_node(P)

/datum/spacewalk_grid/Destroy()
	for(var/datum/point/P in filled_nodes)
		release_node(P)
	if(available_nodes.len > 1)
		log_debug("Multiple nodes left behind after SW grid qdel: [available_nodes.len]")
		for(var/datum/point/P in available_nodes)
			log_debug("([P.x],[P.y])")

/datum/spacewalk_grid/proc/add_available_node(datum/point/P)
	var/hash = P.hash()
	if(hash in all_nodes)
		log_debug("Hash overlap! [hash]")
	all_nodes[P.hash()] = P
	available_nodes |= P

// We call this to flag a node as in use - all required variables will be
// ready after this is called
/datum/spacewalk_grid/proc/consume_node(datum/point/P)
	filled_nodes |= P
	available_nodes -= P
	// This proc adds any new neighbors to the list of available nodes
	P.get_empty_neighbors(src)
	if(min_x > P.x)
		min_x = P.x
	else if(max_x < P.x)
		max_x = P.x
	if(min_y > P.y)
		min_y = P.y
	else if(max_y < P.y)
		max_y = P.y
	P.set_neighbors(src)

// You can call this with an active point, to remove it from the grid -
// this is important if you want to separate a z level from the network
/datum/spacewalk_grid/proc/release_node(datum/point/P)
	filled_nodes -= P
	available_nodes |= P
	// Go through each neighbor node, and delete it if it's not
	// next to any other active nodes
	for(var/datum/point/P2 in P.neighbors)
		var/isolated = P2.has_no_neighbors(src)
		if(isolated)
			if(!P2.spl)
				available_nodes -= P2
				all_nodes -= P2.hash()
				qdel(P)
			else
				log_debug("Isolated z level at ([P2.x],[P2.y]): [P2.spl.zpos]")
	P.deactivate()
	P.neighbors.Cut()

	// Now that we've cleaned out inactive nodes, we will update the bounds
	var/datum/point/outer_bound
	if(P.x == max_x)
		for(var/i = min_y, i <= max_y, i++)
			outer_bound = get(P.x, i)
			if(!isnull(outer_bound)) // There is still an active node in this column
				break
		if(isnull(outer_bound))
			max_x--

	if(P.x == min_x)
		for(var/i = min_y, i <= max_y, i++)
			outer_bound = get(P.x, i)
			if(!isnull(outer_bound)) // There is still an active node in this column
				break
		if(isnull(outer_bound))
			min_x++

	if(P.y == max_y)
		for(var/i = min_x, i <= max_x, i++)
			outer_bound = get(i, P.y)
			if(!isnull(outer_bound)) // There is still an active node in this column
				break
		if(isnull(outer_bound))
			max_y--

	if(P.y == min_y)
		for(var/i = min_x, i <= max_x, i++)
			outer_bound = get(i, P.y)
			if(!isnull(outer_bound)) // There is still an active node in this column
				break
		if(isnull(outer_bound))
			min_y++


// If the node isn't in the grid, this will return null
/datum/spacewalk_grid/proc/get(x,y, allow_empty = 0)
	var/datum/point/P = all_nodes["([x],[y])"]
	if(!allow_empty && !(P in filled_nodes))
		P = null // active nodes only
	return P

/datum/spacewalk_grid/proc/get_width()
	return 1 + max_x - min_x

/datum/spacewalk_grid/proc/get_height()
	return 1 + max_y - min_y

// This function chooses an available point next to any node in the grid
/datum/spacewalk_grid/proc/get_empty_node()
	var/datum/point/P = pick(available_nodes)
	if(isnull(P))
		throw EXCEPTION("The `available_nodes` list was either empty or contained a null entry")
	consume_node(P)
	return P

// This function is called repeatedly to build the map
/datum/spacewalk_grid/proc/add_level(datum/space_level/S)
	var/datum/point/P = get_empty_node()
	P.set_space_level(S)


// This proc substantiates the grid of points used to determine routes between levels
// Separating this from initialization gives us time in which we can add more crosslink z levels
// before we bake in all our connections
/datum/zlev_manager/proc/route_linkage()
	var/list/crosslinks = list()
	var/datum/space_level/D
	for(var/A in z_list)
		D = z_list[A]
		if(D.linkage == CROSSLINKED)
			crosslinks.Add(D)
			D.reset_connections()

	// We create an imaginary, square, grid, with dimensions that are
	// twice the number of z levels, plus one, per side

	// This is big enough to hold a straight line from the center to any side
	// `point_grid` is indexed as a 2 way matrix of these points
	// `grid` is a flat list of these same above points

	// Each point represents a possible z level position
	if(linkage_map)
		qdel(linkage_map)
	linkage_map = new

	// Now, we pop entries in a random order from our list of space levels
	// and assign its connections based on the grid
	while(crosslinks.len)
		D = pick(crosslinks)
		crosslinks.Remove(D)
		// Add it to our space grid
		D.add_to_space_network(linkage_map)

// Used to loop through turfs in world, now just goes through each level's
// transit turf cache
/datum/zlev_manager/proc/setup_space_destinations(force_all_rebuilds = FALSE)
	var/timer = start_watch()
	log_debug("Assigning space turf destinations...")
	var/datum/space_level/D
	var/datum/space_level/E
	var/turf/space/S
	var/list/levels_to_rebuild = unbuilt_space_transitions

	if(force_all_rebuilds)
		// Assuming we don't have like 9000 zlevels this shouldn't hurt
		levels_to_rebuild = list()
		for(var/A in z_list)
			levels_to_rebuild.Add(z_list[A])


	for(var/foo in levels_to_rebuild) //Define the transitions of the z levels
		D = foo
		log_debug("Z level [D.zpos]")
		switch(D.linkage)
			if(UNAFFECTED)
				for(var/B in D.transit_west | D.transit_east | D.transit_south | D.transit_north)
					S = B
					S.remove_transitions()
			if(SELFLOOPING,CROSSLINKED)
				// Left border
				for(var/B in D.transit_west)
					S = B
					E = D.get_connection(Z_LEVEL_WEST)
					S.set_transition_west(E.zpos)

				// Right border
				for(var/B in D.transit_east)
					S = B
					E = D.get_connection(Z_LEVEL_EAST)
					S.set_transition_east(E.zpos)

				// Bottom border
				for(var/B in D.transit_south)
					S = B
					E = D.get_connection(Z_LEVEL_SOUTH)
					S.set_transition_south(E.zpos)

				// Top border
				for(var/B in D.transit_north)
					S = B
					E = D.get_connection(Z_LEVEL_NORTH)
					S.set_transition_north(E.zpos)
		unbuilt_space_transitions -= D

	log_debug("Assigning space turf destinations complete. Took [stop_watch(timer)]s.")

// Nothing fancy, just does it all at once
/datum/zlev_manager/proc/do_transition_setup()
	route_linkage()
	setup_space_destinations(force_all_rebuilds = TRUE)

// A debugging proc that expresses the map's shape as a bunch of turfs
/datum/zlev_manager/proc/map_as_turfs(turf/center)
	// size is odd
	// -1, /2 to get distance from the center
	// center - radius = bottom left coordinate
	var/datum/point/P
	var/turf/our_spot
	var/grid_desc = ""
	for(var/i = linkage_map.min_x, i <= linkage_map.max_x, i++)
		for(var/j = linkage_map.min_y, j <= linkage_map.max_y, j++)
			P = linkage_map.get(i, j)
			our_spot = locate(center.x + i, center.y + j, center.z)
			grid_desc = "([i],[j])"
			if(!isnull(P))
				our_spot = our_spot.ChangeTurf(/turf/simulated/floor/plating/snow)
				grid_desc += ": Z level [P.spl.zpos]. "
				var/datum/space_level/up = P.spl.get_connection(Z_LEVEL_NORTH)
				var/datum/space_level/down = P.spl.get_connection(Z_LEVEL_SOUTH)
				var/datum/space_level/right = P.spl.get_connection(Z_LEVEL_EAST)
				var/datum/space_level/left = P.spl.get_connection(Z_LEVEL_WEST)
				grid_desc += "Up: [up.zpos], "
				grid_desc += "Down: [down.zpos], "
				grid_desc += "Right: [right.zpos], "
				grid_desc += "Left: [left.zpos]"
			else
				our_spot = our_spot.ChangeTurf(/turf/simulated/floor/fakespace)
			our_spot.desc = grid_desc
