/*

This file contains the code necessary to do the display code for cult spirits.

It reuses a lot of code from the AIEye cameraNetwork. In order to work properly, some of those files needed to be modified as well.

*/


/proc/isCultRune(var/viewpoint)
	var/obj/effect/rune/test_rune = viewpoint
	if(test_rune)
		return TRUE
	return FALSE


/proc/isCultViewpoint(var/viewpoint)
	var/obj/cult_viewpoint/vp = viewpoint
	if(vp)
		return TRUE
	return FALSE
	
/*
RUNE JUNK
*/

/obj/effect/rune/proc/can_use()
	return TRUE

/obj/effect/rune/proc/can_see()
	return hear(view_range, get_turf(src))

