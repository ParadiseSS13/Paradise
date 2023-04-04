/datum/event/falsealarm
	announceWhen	= 0
	endWhen			= 1

/datum/event/falsealarm/announce()
	var/weight = pickweight(list(EVENT_LEVEL_MUNDANE = 60, EVENT_LEVEL_MODERATE = 30, EVENT_LEVEL_MAJOR = 10))
	var/datum/event_container/container = SSevents.event_containers[weight]
	var/datum/event/E = container.acquire_event()
	var/datum/event/Event = new E
	message_admins("False Alarm: [Event]")
	Event.announce() 	//just announce it like it's happening
	Event.kill() 		//do not process this event - no starts, no ticks, no ends
