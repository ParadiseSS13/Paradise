/**
 * tgui state: flock_state
 *
 * Checks that the user is a flock overmind, or an admin.
 */

GLOBAL_DATUM_INIT(flock_state, /datum/ui_state/flockmind, new)

/datum/ui_state/flockmind/can_use_topic(src_object, mob/user)
	if(istype(user, /mob/camera/flock/overmind))
		return UI_INTERACTIVE
	if(check_rights_for(user.client, R_ADMIN))
		return UI_INTERACTIVE
	return UI_CLOSE
