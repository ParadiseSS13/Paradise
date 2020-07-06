 /**
  * tgui state: hands_state
  *
  * Checks that the src_object is in the user's hands.
 **/

GLOBAL_DATUM_INIT(tgui_hands_state, /datum/tgui_state/hands_state, new)

/datum/tgui_state/hands_state/can_use_topic(src_object, mob/user)
	. = user.shared_tgui_interaction(src_object)
	if(. > STATUS_CLOSE)
		return min(., user.hands_can_use_tgui_topic(src_object))

/mob/proc/hands_can_use_tgui_topic(src_object)
	return STATUS_CLOSE

/mob/living/hands_can_use_tgui_topic(src_object)
	if(is_in_active_hand(src_object) || is_in_inactive_hand(src_object))
		return STATUS_INTERACTIVE
	return STATUS_CLOSE

/mob/living/silicon/robot/hands_can_use_tgui_topic(src_object)
	if(activated(src_object))
		return STATUS_INTERACTIVE
	return STATUS_CLOSE
