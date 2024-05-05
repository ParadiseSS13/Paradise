/**
 * tgui state: viewer_state
 *
 * State for only viewing, regardless of distance. Different from observer_state, which grants interactivity exclusively if an observer/admin.
 */

GLOBAL_DATUM_INIT(viewer_state, /datum/ui_state/viewer_state, new)

/datum/ui_state/viewer_state/can_use_topic(src_object, mob/user)
	return UI_UPDATE
