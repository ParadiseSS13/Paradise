/*

This file contains the code necessary to do the display code for cult spirits.

It reuses a lot of code from the AIEye cameraNetwork. In order to work properly, some of those files needed to be modified as well.

*/


/proc/isCultRune(var/viewpoint)
	var/obj/effect/rune/test_rune = viewpoint
	if (test_rune)
		return TRUE
	return FALSE


/proc/isCultViewpoint(var/viewpoint)
	var/obj/cult_viewpoint/vp = viewpoint
	if (vp)
		return TRUE
	return FALSE


/datum/visibility_chunk/cult/validViewpoint(var/atom/viewpoint)
	var/turf/point = locate(src.x + 8, src.y + 8, src.z)
	if(get_dist(point, viewpoint) > 24)
		return FALSE

	if (isCultRune(viewpoint) || isCultViewpoint(viewpoint))
		return viewpoint:can_use()
	return FALSE


/datum/visibility_chunk/cult/getVisibleTurfsForViewpoint(var/viewpoint)
	var/obj/effect/rune/rune = viewpoint
	if (rune)
		return rune.can_see()
	var/obj/cult_viewpoint/cvp = viewpoint
	if (cvp)
		return cvp.can_see()
	return null


/datum/visibility_chunk/cult/findNearbyViewpoints()
	for(var/obj/cult_viewpoint/vp in range(16, locate(x + 8, y + 8, z)))
		if(vp.can_use())
			viewpoints += vp
	for(var/obj/effect/rune/rune in range(16, locate(x + 8, y + 8, z)))
		viewpoints += rune


/datum/visibility_network/cult
	ChunkType = /datum/visibility_chunk/cult


/datum/visibility_network/cult/validViewpoint(var/viewpoint)
	if (isCultRune(viewpoint) || isCultViewpoint(viewpoint))
		return viewpoint:can_use()
	return FALSE

/datum/visibility_network/cult/getViewpointFromMob(var/mob/currentMob)
	for(var/obj/cult_viewpoint/currentView in currentMob)
		return currentView
	return FALSE


/datum/visibility_interface/cult
	chunk_type = /datum/visibility_chunk/cult

	
/*
RUNE JUNK
*/

/obj/effect/rune/proc/can_use()
	return TRUE

/obj/effect/rune/proc/can_see()
	return hear(view_range, get_turf(src))

