 /**
  * tgui state: self_state
  *
  * Only checks that the user and src_object are the same.
 **/

GLOBAL_DATUM_INIT(tgui_self_state, /datum/tgui_state/self_state, new)

/datum/tgui_state/self_state/can_use_topic(src_object, mob/user)
	if(src_object != user)
		return STATUS_CLOSE
	return user.shared_tgui_interaction(src_object)
