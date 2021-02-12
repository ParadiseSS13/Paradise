/**
 * tgui state: physical_state
 *
 * Short-circuits the default state to only check physical distance.
 */

GLOBAL_DATUM_INIT(physical_state, /datum/ui_state/physical, new)

/datum/ui_state/physical/can_use_topic(src_object, mob/user)
	. = user.shared_ui_interaction(src_object)
	if(. > STATUS_CLOSE)
		return min(., user.physical_can_use_topic(src_object))

/mob/proc/physical_can_use_topic(src_object)
	return STATUS_CLOSE

/mob/living/simple_animal/revenant/physical_can_use_topic(src_object)
	return STATUS_UPDATE

/mob/living/physical_can_use_topic(src_object)
	return shared_living_ui_distance(src_object)

/mob/living/silicon/physical_can_use_topic(src_object)
	return max(STATUS_UPDATE, shared_living_ui_distance(src_object)) // Silicons can always see.

/mob/living/silicon/ai/physical_can_use_topic(src_object)
	return STATUS_UPDATE // AIs are not physical.
