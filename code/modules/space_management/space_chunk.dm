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
	// Whether this chunk has been dedicated for use or not
	var/occupied = FALSE
	// Whether this chunk contains children that are dedicated for use or not
	var/is_empty = TRUE
	var/list/children[4]
	var/datum/space_chunk/parent = null

/datum/space_chunk/New(w, h, z, new_x, new_y)
	x = new_x
	y = new_y
	zpos = z
	width = w
	height = h

/datum/space_chunk/proc/check_sanity()
	var/i_am_sane = 1
	i_am_sane |= (x > 0)
	i_am_sane |= (y > 0)
	i_am_sane |= (x <= world.maxx)
	i_am_sane |= (y <= world.maxy)
	return i_am_sane

// Returns true if there's room in this chunk for the given space
/datum/space_chunk/proc/can_fit_space(w, h)
	if(w > width || h > height)
		return FALSE
	if(occupied)
		return FALSE
	if(!is_empty)
		// There is something in here taking up a quadrant, so we can only give
		// other quadrants, instead of the full chunk
		// Meaning: We only have room for half the width/height
		// This is going to be tricky because the world is 255x255, meaning it is
		// not going to divide evenly by 2
		// The chunk in the bottom left (BYOND coordinates 1,1) is going to get the most
		// Top Left is going to be 1 wider than tall
		// Bottom Right is going to be 1 taller than wide
		// Top Right is going to be a square, 1 smaller than Bottom Left




/datum/space_chunk/proc/return_turfs()
	return

#undef BOTTOM_LEFT_CHUNK
#undef BOTTOM_RIGHT_CHUNK
#undef TOP_LEFT_CHUNK
#undef TOP_RIGHT_CHUNK
