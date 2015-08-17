/datum/nano_module
	var/name
	var/host

/datum/nano_module/New(var/host)
	src.host = host

/datum/nano_module/nano_host()
	return host ? host : src

/datum/nano_module/proc/can_still_topic(var/datum/topic_state/state = default_state)
	return CanUseTopic(usr, state) == STATUS_INTERACTIVE
