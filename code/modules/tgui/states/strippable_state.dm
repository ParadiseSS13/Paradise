/**
 * tgui state: strippable_state
 *
 * Checks if user can strip the mob src_object
 */


GLOBAL_DATUM_INIT(strippable_state, /datum/ui_state/strippable_state, new)

/datum/ui_state/strippable_state/can_use_topic(src_object, mob/user)
	if(!ismob(src_object))
		return UI_CLOSE
	. = user.default_can_use_topic(src_object)
	if(!HAS_TRAIT(user, TRAIT_CAN_STRIP))
		. = min(., UI_UPDATE)
	var/mob/M = src_object
	if(!isturf(M.loc))
		. = min(., UI_DISABLED)
