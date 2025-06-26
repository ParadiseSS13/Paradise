/datum/map_template/ruin/proc/get_size()
	if(!width || !height)
		CRASH("size of [name]/[suffix] requested before loaded size")

	return width * height
