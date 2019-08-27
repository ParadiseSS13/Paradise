/datum/proc/nano_host()
	return src

/datum/proc/CanUseTopic(var/mob/user, var/datum/topic_state/state)
	var/src_object = nano_host()
	return state.can_use_topic(src_object, user)

/datum/topic_state/proc/href_list(var/mob/user)
	return list()

/datum/topic_state/proc/can_use_topic(var/src_object, var/mob/user)
	return STATUS_CLOSE

/mob/proc/shared_nano_interaction()
	if(stat || !client)
		return STATUS_CLOSE						// no updates, close the interface
	else if(incapacitated())
		return STATUS_UPDATE					// update only (orange visibility)
	return STATUS_INTERACTIVE

/mob/dead/observer/shared_nano_interaction()
	if(check_rights(R_ADMIN, 0, src))
		return STATUS_INTERACTIVE				// Admins are more equal
	return STATUS_UPDATE						// Ghosts can view updates

/mob/living/silicon/ai/shared_nano_interaction()
	if(apc_override)
		return STATUS_INTERACTIVE
	if(lacks_power())
		return STATUS_CLOSE
	if(check_unable(1, 0))
		return STATUS_CLOSE
	return ..()

/mob/living/silicon/robot/shared_nano_interaction()
	. = STATUS_INTERACTIVE
	if(!cell || cell.charge <= 0)
		return STATUS_CLOSE
	if(lockcharge)
		. = STATUS_DISABLED
	return min(., ..())
