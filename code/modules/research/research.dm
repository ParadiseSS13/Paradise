/*
General Explaination:
The research datum contains all points, technodes and designs of a particular research network, it also containts the procs required
to manipulate these things. Nothing should ever have custom procs for adding/taking points, technodes or designs directly from the vars, it should use the
procs in this file.

Each RnD Network Manager contains its own research datum, meaning all research is local and will be destroyed along with the console.

Point operations are always performed through lists in the form of ("Type" = amount), e.g. list("Research" = 500), if an operation attempts
to use a point type that does not exist in SSresearch then that point type will be removed.

If you want to add a new point type, look at SSResearch.
*/

/// Holder for all the existing, archived, and known tech. Individual to each network controller.
/datum/research
	// These lists hold datum/tech


	/// List of all possible technodes, in direct datum references.
	var/list/possible_technodes = list()
	/// List of technodes we can see, in direct datum references.
	var/list/visible_technodes = list()
	/// List of locally known technodes, list of id -> datum mappings.
	var/list/known_technodes = list()


	/// List of all designs
	var/list/possible_designs = list()
	/// List of available designs, list of id -> datum mappings
	var/list/known_designs = list()
	/// List of designs that have been blacklisted by the server controller
	var/list/blacklisted_designs = list()
	/// Used during the rnd sync system, to ensure that blacklists are reverted, then cleared.
	var/list/unblacklisted_designs = list()
	/// Points for research operations.
	var/list/research_points = list()
	/// Total research points we've generated in this research datum
	var/list/total_points = list()

/datum/research/New()
	// MON DIEU!!! - Im not even gonna question why this monologue is here, or why the french wrote our original research.
	// These are semi-global, but not TOTALLY global?
	// Using research disks, you can get techs/designs from one research datum
	// onto another. What consequences this could have, I am presently unsure, but
	// I imagine nothing good.
	for(var/T in subtypesof(/datum/technode))
		possible_technodes += new T(src)
	for(var/D in subtypesof(/datum/design))
		possible_designs += new D(src)
	research_points = SSresearch.point_types
	for(var/i in research_points)
		research_points[i] = 0
	total_points = SSresearch.point_types
	for(var/i in total_points)
		total_points[i] = 0
	RefreshResearch()

/// Anything calling this proc should use the returned value to remove points from itself.
/datum/research/proc/addpoints(list/points_list)
	points_list &= SSresearch.point_types // If a point type isnt recognised, remove it.
	for(var/i in points_list)
		if((i in research_points) && points_list[i] > 0)
			research_points[i] = FLOOR(research_points[i] + points_list[i], 0.1)
			return points_list // So the caller doesnt delete points that werent sent.
		if((i in total_points) && points_list[i] > 0)
			total_points[i] = FLOOR(total_points[i] + points_list[i], 0.1)
	RefreshResearch() // Update visibility when adding points to ensure nodes show correctly.

// Autobalance determines if requesting more points then we have will automatically reduce the request or just cancel it.
/// Anything calling this proc should use the returned value to add points to itself.
/datum/research/proc/takepoints(list/points_list, autobalance = TRUE)
	points_list &= SSresearch.point_types // If a point type isnt recognised, remove it.
	for(var/i in points_list)
		if(research_points[i] < points_list[i] && autobalance == TRUE)
			points_list[i] = research_points[i]
		if(research_points[i] < points_list[i] && autobalance == FALSE)
			return
		if((i in research_points) && points_list[i] > 0)
			research_points[i] = FLOOR(research_points[i] - points_list[i], 0.1)
			return points_list
		log_debug("Research point withdrawl failed unexpectedly.")
		return

/// Checks to see if technode has all the required pre-reqs. Output: TRUE/FALSE
/datum/research/proc/technode_has_prereqs(datum/technode/T)
	if(T.starting_node == TRUE)
		return TRUE
	var/prereqs_met = 0
	for(var/i in T.prereqs)
		if(i in known_technodes)
			prereqs_met += 1
	if(prereqs_met == T.prereqs.len)
		return TRUE
	return FALSE

/// Checks to see if research datum can buy this technode. Output: TRUE/FALSE
/datum/research/proc/can_buy_technode(datum/technode/T)
	var/costs_met = 0
	for(var/i in T.cost)
		if(research_points[i] >= T.cost[i])
			costs_met += 1
	if(costs_met == T.cost.len)
		return TRUE
	return FALSE

/// Output: TRUE/FALSE (success/fail)
/datum/research/proc/unlock_technode(datum/technode/T)
	if(T.id in known_technodes)
		log_debug("(Unlock Node) Technode [T.name] attempted unlock but was already unlocked.")
		return FALSE
	var/list/i = list("[T.id]" = T)
	known_technodes += i
	for(var/d in T.unlocks)
		AddDesign2Known(find_possible_design_by_id(d))
	RefreshResearch()
	log_debug("(Unlock Node) Technode [T.name] successfully unlocked.") // MIXTODO - Remove logging later
	return TRUE

/// Checks if technode can be brought, if so, buys it. Output: TRUE/FALSE (success/fail)
/datum/research/proc/buy_technode(datum/technode/T)
	if(!check_technode_visibility(T))
		log_debug("(Buy Node) Attempted to buy Technode [T.name] but it was not visible.")
		return FALSE // We can't see this node, meaning we cannot unlock it normally.
	if(T.id in known_technodes)
		return FALSE // No buying the same node twice.
	if(technode_has_prereqs(T) == TRUE && can_buy_technode(T) == TRUE)
		for(var/i in T.cost)
			research_points[i] -= T.cost[i]
			unlock_technode(T)
		log_debug("(Buy Node) Technode [T.name] successfully brought.") // MIXTODO - Remove logging later
		return TRUE
	log_debug("(Buy Node) Technode [T.name] failed buy.")// MIXTODO - Remove logging later
	return FALSE

/// Checks if the technode is visible, adds/removes it from visible_technodes if required. Output: TRUE/FALSE
/datum/research/proc/check_technode_visibility(datum/technode/T)
	if(T.id in known_technodes)
		if(T in visible_technodes)
			visible_technodes -= T
		// log_debug("(Check Vis) Technode [T.name] was already known.") // MIXTODO - Remove logging later
		return FALSE // Technode is already known, we don't need to check this.
	if(T.starting_node == FALSE && T.prereqs.len == 0)
		// log_debug("(Check Vis) Technode [T.name] has no prereqs and isnt a starting node.") // MIXTODO - Remove logging later
		return FALSE
	if(T.cost_hidden.len > 0)
		var/tc = 0
		for(var/i in T.cost_hidden)
			if(total_points[i] > T.cost_hidden[i])
				tc += 1
		if(tc == T.cost_hidden.len)
			// log_debug("(Check Vis - Hidden) Technode [T.name] was declared visible.") // MIXTODO - Remove logging later
			return TRUE
		// log_debug("(Check Vis - Hidden) Technode [T.name] was declared NOT visible.") // MIXTODO - Remove logging later
		return FALSE
	if(technode_has_prereqs(T))
		if(!(T in visible_technodes))
			visible_technodes += T
		// log_debug("(Check Vis) Technode [T.name] was declared visible.") // MIXTODO - Remove logging later
		return TRUE
	// log_debug("(Check Vis) Technode [T.name] was declared NOT visible.") // MIXTODO - Remove logging later
	return FALSE

/// Checks possible technode list for id, returns T if found.
/datum/research/proc/id_to_possible_technode(id)
	for(var/datum/technode/T in possible_technodes)
		if(T.id == id)
			return T

/datum/research/proc/design_id_to_technode(id)
	for(var/datum/technode/T in possible_technodes)
		if(id in T.unlocks)
			return T
		return FALSE

/datum/research/proc/DesignHasReqs(datum/design/D)
	if(D.id in blacklisted_designs)
		return FALSE
	if(D.requires_whitelist && !(D.id in known_designs))
		return FALSE
	var/datum/technode/T = design_id_to_technode(D.id)
	if(!T)
		return TRUE // No technode unlocks this design and it doesnt require a disk or has already been put in, it should be unlocked.
	if(T.id in known_technodes)
		return TRUE
	return FALSE

/datum/research/proc/CanAddDesign2Known(datum/design/D)
	if(D.id in known_designs)
		return FALSE
	if(!DesignHasReqs(D))
		return FALSE
	return TRUE

/datum/research/proc/AddDesign2Known(datum/design/D)
	if(!D)
		return FALSE
	if(D in known_designs)
		return FALSE
	known_designs[D.id] = D
	return TRUE

//Refreshes visible_technodes and known_designs lists.
//Input/Output: n/a
/datum/research/proc/RefreshResearch()
	for(var/datum/technode/PT in possible_technodes)
		check_technode_visibility(PT)
	for(var/datum/design/PD in possible_designs)
		if(CanAddDesign2Known(PD))
			AddDesign2Known(PD)
	if(length(blacklisted_designs)) // No need to run this unless there are blacklisted designs.
		known_designs -= blacklisted_designs

/datum/research/proc/find_possible_design_by_id(id)
	for(var/datum/design/i in possible_designs)
		if(i.id == id)
			return i

/datum/research/proc/FindDesignByID(id)
	return known_designs[id]

//Autolathe files
/datum/research/autolathe

/datum/research/autolathe/AddDesign2Known(datum/design/D)
	if(D.locked || !(D.build_type & (AUTOLATHE|PROTOLATHE|CRAFTLATHE)))
		return FALSE

	for(var/mat in D.materials)
		if(mat != MAT_METAL && mat != MAT_GLASS)
			return FALSE

	return ..()

///Gamma Armoury autolathe files
/datum/research/autolathe/gamma

/datum/research/autolathe/gamma/AddDesign2Known(datum/design/D)
	if(!(D.build_type & (AUTOLATHE|PROTOLATHE|CRAFTLATHE|GAMMALATHE)))
		return FALSE
	return ..()

//Biogenerator files
/datum/research/biogenerator/New()
	for(var/T in (subtypesof(/datum/technode)))
		possible_technodes += new T(src)
	for(var/path in subtypesof(/datum/design))
		var/datum/design/D = new path(src)
		possible_designs += D
		if((D.build_type & BIOGENERATOR) && ("initial" in D.category))
			AddDesign2Known(D)

/datum/research/biogenerator/CanAddDesign2Known(datum/design/D)
	if(!(D.build_type & BIOGENERATOR))
		return FALSE
	return ..()

//Smelter files
/datum/research/smelter/New()
	for(var/T in (subtypesof(/datum/technode)))
		possible_technodes += new T(src)
	for(var/path in subtypesof(/datum/design))
		var/datum/design/D = new path(src)
		possible_designs += D
		if((D.build_type & SMELTER) && ("initial" in D.category))
			AddDesign2Known(D)

/datum/research/smelter/CanAddDesign2Known(datum/design/D)
	if(!(D.build_type & SMELTER))
		return FALSE
	return ..()
