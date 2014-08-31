/datum/visibility_chunk/camera

/datum/visibility_chunk/camera/validViewpoint(var/viewpoint)
	var/obj/machinery/camera/c = viewpoint
	if(!c)
		return FALSE
	if(!c.can_use())
		return FALSE
	var/turf/point = locate(src.x + 8, src.y + 8, src.z)
	if(get_dist(point, c) > 24)
		return FALSE
	return TRUE


/datum/visibility_chunk/camera/getVisibleTurfsForViewpoint(var/viewpoint)
	var/obj/machinery/camera/c = viewpoint
	return c.can_see()


/datum/visibility_chunk/camera/findNearbyViewpoints()
	for(var/obj/machinery/camera/c in range(16, locate(x + 8, y + 8, z)))
		if(c.can_use())
			viewpoints += c
