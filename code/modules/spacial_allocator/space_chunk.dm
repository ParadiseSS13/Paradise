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
