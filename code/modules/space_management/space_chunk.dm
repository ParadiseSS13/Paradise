// I'd use consts here, but our coding standard is silly and demonizes usage
// of that.
#define BOTTOM_LEFT_CHUNK 	1
#define BOTTOM_RIGHT_CHUNK 	2
#define TOP_LEFT_CHUNK 			3
#define TOP_RIGHT_CHUNK			4
/datum/space_chunk
	var/x
	var/y
	var/width
	var/height
	var/zpos
	// Whether dedicated for use or not
	var/occupied = FALSE
	// Whether the chunk contains used children or not
	var/is_empty = TRUE
	var/list/children = list()
	var/datum/space_chunk/parent = null

/datum/space_chunk/New(new_x, new_y, z, w, h)
	x = new_x
	y = new_y
	zpos = z
	width = w
	height = h

/datum/space_chunk/Destroy()
	set_occupied(FALSE)
	if(parent)
		parent.children -= src
	QDEL_LIST(children)
	parent = null
	. = ..()

/datum/space_chunk/proc/can_fit_space(w, h)
	if(w > width || h > height)
		return FALSE
	if(occupied)
		return FALSE
	if(is_empty)
		return TRUE
	for(var/datum/space_chunk/C in children)
		if(C.can_fit_space(w, h))
			return TRUE
	return FALSE

// Recursively drops down the tree and finds the most efficient chunk to use
/datum/space_chunk/proc/get_optimal_chunk(w, h)
	if(w > width || h > height)
		return null
	if(occupied)
		return null
	if(is_empty)
		return src
	var/datum/space_chunk/optimal_chunk
	var/optimal_chunk_optimalness = 99999
	for(var/datum/space_chunk/C in children)
		var/datum/space_chunk/C2 = C.get_optimal_chunk(w, h)
		if(!C2)
			continue
		var/optimalness = C2.width + C2.height-w-h
		if(optimalness < optimal_chunk_optimalness)
			optimal_chunk_optimalness = optimalness
			optimal_chunk = C2
	return optimal_chunk

/datum/space_chunk/proc/set_occupied(new_occupied)
	var/datum/space_chunk/C = parent
	if(new_occupied)
		occupied = TRUE
		while(C)
			C.is_empty = FALSE
			C = C.parent
	else
		occupied = FALSE
		while(C)
			var/is_children_empty = TRUE
			for(var/datum/space_chunk/C2 in C.children)
				if(!C2.is_empty || C2.occupied)
					is_children_empty = FALSE
			if(!is_children_empty)
				break
			C.is_empty = TRUE
			C = C.parent

/datum/space_chunk/proc/check_sanity()
	var/i_am_sane = 1
	i_am_sane |= (x > 0)
	i_am_sane |= (y > 0)
	i_am_sane |= (x <= world.maxx)
	i_am_sane |= (y <= world.maxy)
	return i_am_sane

/datum/space_chunk/proc/return_turfs()
	return

#undef BOTTOM_LEFT_CHUNK
#undef BOTTOM_RIGHT_CHUNK
#undef TOP_LEFT_CHUNK
#undef TOP_RIGHT_CHUNK