/datum/event/falsealarm
	announceWhen	= 0
	endWhen			= 1

/datum/event/falsealarm/announce()
	var/datum/event_container/container = SSevents.event_containers[pick(6;EVENT_LEVEL_MUNDANE, 3;EVENT_LEVEL_MODERATE, 1;EVENT_LEVEL_MAJOR)]
	var/datum/event_meta/E = container.acquire_event()
	var/datum/event/Event = new E.event_type
	message_admins("False Alarm: [Event]")
	Event.announce() 	//just announce it like it's happening
	Event.kill() 		//do not process this event - no starts, no ticks, no ends
