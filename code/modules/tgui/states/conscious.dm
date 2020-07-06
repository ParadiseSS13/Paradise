 /**
  * tgui state: conscious_state
  *
  * Only checks if the user is conscious.
 **/

GLOBAL_DATUM_INIT(tgui_conscious_state, /datum/tgui_state/conscious_state, new)

/datum/tgui_state/conscious_state/can_use_topic(src_object, mob/user)
	if(user.stat == CONSCIOUS)
		return STATUS_INTERACTIVE
	return STATUS_CLOSE
