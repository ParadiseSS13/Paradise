/datum/ventcrawl_node
	var/obj/machinery/atmospherics/atmos
	/// The node we just came from
	var/datum/ventcrawl_node/previous_node
	/// How many steps it's taken to get here from the start
	var/number_tiles = 0
	/// The A* node weight (f_value = number_of_tiles + heuristic)
	var/f_value = INFINITY

/datum/ventcrawl_node/New(obj/machinery/atmospherics/atmos, datum/ventcrawl_node/incoming_previous_node, obj/machinery/atmospherics/incoming_goal)
	src.atmos = atmos
	src.previous_node = incoming_previous_node
	if(previous_node)
		src.number_tiles = previous_node.number_tiles + 1
	src.f_value = number_tiles + get_dist_euclidian(atmos, incoming_goal)

/datum/ventcrawl_node/Destroy(force)
	previous_node = null
	return ..()

/proc/HeapPathWeightCompareVent(datum/ventcrawl_node/a, datum/ventcrawl_node/b)
	return b.f_value - a.f_value

/**
 * Basic A-star implementation (I think), for pathfinding through vents.
 */
/datum/pathfind/ventcrawl
	/// The movable we are pathing
	var/atom/movable/requester
	/// The vent we are trying to pathfind to
	var/obj/machinery/atmospherics/unary/end
	/// The open list/stack we pop nodes out from (TODO: make this a normal list and macro-ize the heap operations to reduce proc overhead)
	var/datum/heap/open
	/// The list we compile at the end if successful to pass back
	var/list/path
	///An assoc list that serves as the closed list. Key is the turf, points to true if we've seen it before
	var/list/closed_set
	/// If we should delete the first step in the path or not. Used often because it is just the starting point
	var/skip_first = FALSE

/datum/pathfind/ventcrawl/proc/setup(atom/movable/requester, obj/machinery/atmospherics/unary/goal, skip_first, list/datum/callback/on_finish)
	src.requester = requester
	src.end = goal
	src.on_finish = on_finish
	src.skip_first = skip_first

	open = new /datum/heap(/proc/HeapPathWeightCompareVent)
	closed_set = list()

/datum/pathfind/ventcrawl/Destroy(force)
	. = ..()
	requester = null
	end = null
	open = null

/datum/pathfind/ventcrawl/start()
	start = start || requester.loc
	. = ..()
	if(!.)
		return .

	if(start.z != end.z || start == end) //no pathfinding between z levels
		return FALSE

	open.Insert(new /datum/ventcrawl_node(start, null, end))
	closed_set[start] = TRUE
	return TRUE

/datum/pathfind/ventcrawl/search_step()
	. = ..()
	if(!.)
		return .
	if(QDELETED(requester))
		return FALSE

	while(!open.IsEmpty() && !path)
		var/datum/ventcrawl_node/current = open.Pop()
		// var/obj/machinery/atmospherics/fast_neighbor = current.atmos.findConnecting(angle2dir_cardinal(get_angle(current.atmos, end)))
		// if(fast_neighbor && !closed_set[fast_neighbor])
		// 	open.Insert(new /datum/ventcrawl_node(fast_neighbor, current, end)) // try to move towards it first!
		// 	continue
		closed_set[current.atmos] = TRUE

		for(var/dir in GLOB.cardinal)
			if(!(dir & current.atmos.initialize_directions))
				continue
			var/obj/machinery/atmospherics/neighbor = current.atmos.findConnecting(dir)
			if(!neighbor || closed_set[neighbor])
				continue
			if(neighbor == end)
				unwind_path(current)
				return
			open.Insert(new /datum/ventcrawl_node(neighbor, current, end))

		// Stable, we'll just be back later
		if(TICK_CHECK)
			return TRUE
	return TRUE

/datum/pathfind/ventcrawl/finished()
	//we're done! turn our reversed path (end to start) into a path (start to end)
	closed_set = null
	QDEL_NULL(open)
	path ||= list()
	if(skip_first && length(path))
		path.Cut(1, 2)
	hand_back(path)
	return ..()

/datum/pathfind/ventcrawl/proc/unwind_path(datum/ventcrawl_node/unwind_node)
	path = list(end, unwind_node.atmos)

	while(unwind_node.previous_node)
		path += unwind_node.previous_node.atmos
		unwind_node = unwind_node.previous_node

	path = reverselist(path)
