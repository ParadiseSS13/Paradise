/**
 * tgui state: hands_state
 *
 * Checks that the src_object is in the user's hands.
 */

GLOBAL_DATUM_INIT(hands_state, /datum/ui_state/hands_state, new)

/datum/ui_state/hands_state/can_use_topic(src_object, mob/user)
	. = user.shared_ui_interaction(src_object)
	if(. > STATUS_CLOSE)
		return min(., user.hands_can_use_topic(src_object))

/mob/proc/hands_can_use_topic(src_object)
	return STATUS_CLOSE

/mob/living/hands_can_use_topic(src_object)
	if(is_in_active_hand(src_object) || is_in_inactive_hand(src_object))
		return STATUS_INTERACTIVE
	return STATUS_CLOSE

/mob/living/simple_animal/revenant/hands_can_use_topic(src_object)
	return STATUS_UPDATE

/mob/living/silicon/robot/hands_can_use_topic(src_object)
	if(activated(src_object))
		return STATUS_INTERACTIVE
	return STATUS_CLOSE
