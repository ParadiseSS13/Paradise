/datum/event/falsealarm
	announceWhen	= 0
	endWhen			= 1

/datum/event/falsealarm/announce()
	var/weight = pick(EVENT_LEVEL_MUNDANE,EVENT_LEVEL_MUNDANE,EVENT_LEVEL_MUNDANE,EVENT_LEVEL_MODERATE,EVENT_LEVEL_MODERATE,EVENT_LEVEL_MAJOR)
	var/datum/event_container/container = event_manager.event_containers[weight]
	var/datum/event/E = container.acquire_event()
	var/datum/event/Event = new E
	message_admins("False Alarm: [Event]")
	Event.announce() 	//just announce it like it's happening
	Event.kill() 		//do not process this event - no starts, no ticks, no ends
