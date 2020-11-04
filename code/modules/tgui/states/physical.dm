 /**
  * tgui state: physical_state
  *
  * Short-circuits the default state to only check physical distance.
 **/

GLOBAL_DATUM_INIT(tgui_physical_state, /datum/tgui_state/physical, new)

/datum/tgui_state/physical/can_use_topic(src_object, mob/user)
	. = user.shared_tgui_interaction(src_object)
	if(. > STATUS_CLOSE)
		return min(., user.physical_can_use_tgui_topic(src_object))

/mob/proc/physical_can_use_tgui_topic(src_object)
	return STATUS_CLOSE

/mob/living/physical_can_use_tgui_topic(src_object)
	return shared_living_tgui_distance(src_object)

/mob/living/silicon/physical_can_use_tgui_topic(src_object)
	return max(STATUS_UPDATE, shared_living_tgui_distance(src_object)) // Silicons can always see.

/mob/living/silicon/ai/physical_can_use_tgui_topic(src_object)
	return STATUS_UPDATE // AIs are not physical.
