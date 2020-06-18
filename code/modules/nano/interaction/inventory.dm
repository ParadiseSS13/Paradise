/*
	This state checks that the src_object is somewhere in the user's first-level inventory (in hands, on ear, etc.), but not further down (such as in bags).
*/
GLOBAL_DATUM_INIT(inventory_state, /datum/topic_state/inventory_state, new())

/datum/topic_state/inventory_state/can_use_topic(var/src_object, var/mob/user)
	if(!((src_object in user) || user.is_in_active_hand(src_object) || user.is_in_inactive_hand(src_object)))
		return STATUS_CLOSE

	return user.shared_nano_interaction()
