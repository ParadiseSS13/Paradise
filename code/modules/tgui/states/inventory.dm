/**
 * tgui state: inventory_state
 *
 * Checks that the src_object is in the user's top-level (hand, ear, pocket, belt, etc) inventory.
 */

GLOBAL_DATUM_INIT(inventory_state, /datum/ui_state/inventory_state, new)

/datum/ui_state/inventory_state/can_use_topic(src_object, mob/user)
	if(!(src_object in user))
		if(issilicon(user))
			var/mob/living/silicon/robot/R = user
			if(src_object in R.module_active) // Magnetic grippers
				return user.shared_ui_interaction(src_object)
		return STATUS_CLOSE
	return user.shared_ui_interaction(src_object)
