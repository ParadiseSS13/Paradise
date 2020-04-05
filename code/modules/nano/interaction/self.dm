/*
	This state checks that the src_object is the same the as user
*/
GLOBAL_DATUM_INIT(self_state, /datum/topic_state/self_state, new())

/datum/topic_state/self_state/can_use_topic(var/src_object, var/mob/user)
	if(src_object != user)
		return STATUS_CLOSE
	return user.shared_nano_interaction()
