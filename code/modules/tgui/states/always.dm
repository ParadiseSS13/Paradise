
 /**
  * tgui state: always_state
  *
  * Always grants the user UI_INTERACTIVE. Period.
 **/

GLOBAL_DATUM_INIT(tgui_always_state, /datum/tgui_state/always_state, new)

/datum/tgui_state/always_state/can_use_topic(src_object, mob/user)
	return STATUS_INTERACTIVE
