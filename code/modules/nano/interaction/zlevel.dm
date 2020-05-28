/*
	This state checks that the user is on the same Z-level as src_object
*/

GLOBAL_DATUM_INIT(z_state, /datum/topic_state/z_state, new())

/datum/topic_state/z_state/can_use_topic(var/src_object, var/mob/user)
	var/turf/turf_obj = get_turf(src_object)
	var/turf/turf_usr = get_turf(user)
	if(!turf_obj || !turf_usr)
		return STATUS_CLOSE

	return turf_obj.z == turf_usr.z ? STATUS_INTERACTIVE : STATUS_CLOSE
