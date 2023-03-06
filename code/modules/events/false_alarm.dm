/datum/event/falsealarm
	announceWhen	= 0
	endWhen			= 1

/datum/event/falsealarm/announce()
	var/datum/event_container/container = SSevents.event_containers[EVENT_LEVEL_MUNDANE]
	var/datum/event_meta/E = container.acquire_event()
	message_admins("False Alarm: [E.event_type]")
	E.event_type.announce() 	//just announce it like it's happening
	E.event_type.kill() 		//do not process this event - no starts, no ticks, no ends
