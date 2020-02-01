/*
	This checks that the user is a ghost or alternatively an admin. Used for the mob spawner. 
	We don't want any living people somehow getting the menu open and reincarnating while alive
*/

/var/global/datum/topic_state/ghost_state/ghost_state = new()

/datum/topic_state/ghost_state/can_use_topic(var/src_object, var/mob/user)
	if(user.stat == DEAD)
		return STATUS_INTERACTIVE
	if(check_rights(R_ADMIN, 0, src))
		return STATUS_INTERACTIVE
	return STATUS_CLOSE

