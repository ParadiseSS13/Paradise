 /**
  * tgui state: notcontained_state
  *
  * Checks that the user is not inside src_object, and then makes the default checks.
 **/

GLOBAL_DATUM_INIT(tgui_notcontained_state, /datum/tgui_state/notcontained_state, new)

/datum/tgui_state/notcontained_state/can_use_topic(atom/src_object, mob/user)
	. = user.shared_tgui_interaction(src_object)
	if(. > STATUS_CLOSE)
		return min(., user.notcontained_can_use_tgui_topic(src_object))

/mob/proc/notcontained_can_use_tgui_topic(src_object)
	return STATUS_CLOSE

/mob/living/notcontained_can_use_tgui_topic(atom/src_object)
	if(src_object.contains(src))
		return STATUS_CLOSE // Close if we're inside it.
	return default_can_use_tgui_topic(src_object)

/mob/living/silicon/notcontained_can_use_tgui_topic(src_object)
	return default_can_use_tgui_topic(src_object) // Silicons use default bevhavior.

/mob/living/simple_animal/drone/notcontained_can_use_tgui_topic(src_object)
	return default_can_use_tgui_topic(src_object) // Drones use default bevhavior.
