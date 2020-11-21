/**
 * tgui state: contained_state
 *
 * Checks that the user is inside the src_object.
 */

GLOBAL_DATUM_INIT(contained_state, /datum/ui_state/contained_state, new)

/datum/ui_state/contained_state/can_use_topic(atom/src_object, mob/user)
	if(!src_object.contains(user))
		return STATUS_CLOSE
	return user.shared_ui_interaction(src_object)

/atom/proc/contains(atom/location)
	if(!location)
		return FALSE
	if(location == src)
		return TRUE

	return contains(location.loc)
