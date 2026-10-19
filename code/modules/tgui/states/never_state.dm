/**
 * tgui state: never_state
 *
 * Never opens a UI, used for closing UIs when things get unpowered without spaghetti-coding the default_state
 */

GLOBAL_DATUM_INIT(never_state, /datum/ui_state/never_state, new)

/datum/ui_state/never_state/can_use_topic(src_object, mob/user)
	return UI_CLOSE
