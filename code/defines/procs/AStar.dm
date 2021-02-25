/*
A Star pathfinding algorithm
Returns a list of tiles forming a path from A to B, taking dense objects as well as walls, and the orientation of
windows along the route into account.
Use:
your_list = AStar(start location, end location, moving atom, distance proc, max nodes, maximum node depth, minimum distance to target, adjacent proc, atom id, turfs to exclude, check only simulated)

Optional extras to add on (in order):
Distance proc : the distance used in every A* calculation (length of path and heuristic)
MaxNodes: The maximum number of nodes the returned path can be (0 = infinite)
Maxnodedepth: The maximum number of nodes to search (default: 30, 0 = infinite)
Mintargetdist: Minimum distance to the target before path returns, could be used to get
near a target, but not right to it - for an AI mob with a gun, for example.
Adjacent proc : returns the turfs to consider around the actually processed node
Simulated only : whether to consider unsimulated turfs or not (used by some Adjacent proc)

Also added 'exclude' turf to avoid travelling over; defaults to null

Actual Adjacent procs :

	/turf/proc/reachableAdjacentTurfs : returns reachable turfs in cardinal directions (uses simulated_only)

	/turf/proc/reachableAdjacentAtmosTurfs : returns turfs in cardinal directions reachable via atmos

*/

//////////////////////
//PathNode object
//////////////////////

//A* nodes variables
/datum/pathnode
	var/turf/source //turf associated with the PathNode
	var/datum/pathnode/prevNode //link to the parent PathNode
	var/f		//A* Node weight (f = g + h)
	var/g		//A* movement cost variable
	var/h		//A* heuristic variable
	var/nt		//count the number of Nodes traversed

/datum/pathnode/New(s,p,pg,ph,pnt)
	source = s
	prevNode = p
	g = pg
	h = ph
	f = g + h
	source.PNode = src
	nt = pnt

/datum/pathnode/proc/calc_f()
	f = g + h

//////////////////////
//A* procs
//////////////////////

//the weighting function, used in the A* algorithm
/proc/PathWeightCompare(datum/pathnode/a, datum/pathnode/b)
	return a.f - b.f

//reversed so that the Heap is a MinHeap rather than a MaxHeap
/proc/HeapPathWeightCompare(datum/pathnode/a, datum/pathnode/b)
	return b.f - a.f

//wrapper that returns an empty list if A* failed to find a path
/proc/get_path_to(caller, end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableAdjacentTurfs, id = null, turf/exclude = null, simulated_only = TRUE)
	var/list/path = AStar(caller, end, dist, maxnodes, maxnodedepth, mintargetdist, adjacent, id, exclude, simulated_only)
	if(!path)
		path = list()
	return path

//the actual algorithm
/proc/AStar(caller, end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableAdjacentTurfs, id = null, turf/exclude = null, simulated_only = TRUE)
	//sanitation
	var/start = get_turf(caller)
	if(!start)
		return null

	if(maxnodes)
		//if start turf is farther than maxnodes from end turf, no need to do anything
		if(call(start, dist)(end) > maxnodes)
			return null
		maxnodedepth = maxnodes //no need to consider path longer than maxnodes

	var/datum/heap/open = new /datum/heap(/proc/HeapPathWeightCompare) //the open list
	var/list/closed = new() //the closed list
	var/list/path = null //the returned path, if any
	var/datum/pathnode/cur //current processed turf

	//initialization
	open.Insert(new /datum/pathnode(start,null,0,call(start,dist)(end),0))

	//then run the main loop
	while(!open.IsEmpty() && !path)
		//get the lower f node on the open list
		cur = open.Pop() //get the lower f turf in the open list
		closed.Add(cur.source) //and tell we've processed it

		//if we only want to get near the target, check if we're close enough
		var/closeenough
		if(mintargetdist)
			closeenough = call(cur.source, dist)(end) <= mintargetdist

		//if too many steps, abandon that path
		if(maxnodedepth && (cur.nt > maxnodedepth))
			continue

		//found the target turf (or close enough), let's create the path to it
		if(cur.source == end || closeenough)
			path = new()
			path.Add(cur.source)

			while(cur.prevNode)
				cur = cur.prevNode
				path.Add(cur.source)

			break

		//get adjacents turfs using the adjacent proc, checking for access with id
		var/list/L = call(cur.source, adjacent)(caller, id, simulated_only)
		for(var/t in L)
			var/turf/T = t
			if(T == exclude || (T in closed))
				continue

			var/newg = cur.g + call(cur.source, dist)(T)
			if(!T.PNode) //is not already in open list, so add it
				open.Insert(new /datum/pathnode(T,cur,newg,call(T,dist)(end),cur.nt+1))
			else //is already in open list, check if it's a better way from the current turf
				if(newg < T.PNode.g)
					T.PNode.prevNode = cur
					T.PNode.g = newg
					T.PNode.calc_f()
					T.PNode.nt = cur.nt + 1
					open.ReSort(T.PNode)//reorder the changed element in the list

	//cleaning after us
	for(var/datum/pathnode/PN in open.L)
		PN.source.PNode = null
	for(var/t in closed)
		var/turf/T = t
		T.PNode = null

	//reverse the path to get it from start to finish
	if(path)
		for(var/i in 1 to path.len / 2)
			path.Swap(i, path.len - i + 1)

	return path

//Returns adjacent turfs in cardinal directions that are reachable
//simulated_only controls whether only simulated turfs are considered or not
/turf/proc/reachableAdjacentTurfs(caller, ID, simulated_only)
	var/list/L = new()
	var/turf/simulated/T

	for(var/dir in GLOB.cardinal)
		T = get_step(src, dir)
		if(!T || (simulated_only && !istype(T)))
			continue
		if(!T.density && !LinkBlockedWithAccess(T, caller, ID))
			L.Add(T)
	return L

//Returns adjacent turfs in cardinal directions that are reachable via atmos
/turf/proc/reachableAdjacentAtmosTurfs()
	return atmos_adjacent_turfs

/turf/proc/LinkBlockedWithAccess(turf/T, caller, ID)
	var/adir = get_dir(src, T)
	var/rdir = get_dir(T, src)
	var/atom/caller_atom = caller
	if(!istype(caller_atom))
		caller_atom = null

	for(var/obj/structure/window/W in src)
		if(!W.CanAStarPass(ID, adir))
			return TRUE
	for(var/obj/machinery/door/window/W in src)
		if(!W.CanAStarPass(ID, adir))
			return TRUE
	for(var/obj/O in T)
		var/pass_through = FALSE
		if(caller_atom)
			pass_through = caller_atom.CanAStarPassTo(ID, adir, O)
		if(!O.CanAStarPass(ID, rdir, caller) && !pass_through)
			return TRUE

	return FALSE
