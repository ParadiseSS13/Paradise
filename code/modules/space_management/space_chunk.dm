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

/datum/space_chunk/proc/return_turfs()
	return

#undef BOTTOM_LEFT_CHUNK
#undef BOTTOM_RIGHT_CHUNK
#undef TOP_LEFT_CHUNK
#undef TOP_RIGHT_CHUNK
