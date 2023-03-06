/datum/event/falsealarm
	announceWhen	= 0
	endWhen			= 1

/datum/event/falsealarm/announce()
	var/datum/event_container/container = SSevents.false_event_containers
	var/datum/event_meta/E = pick_n_take(container.available_events)
	var/datum/event/Event = new E.event_type
	message_admins("False Alarm: [Event]")
	Event.announce() 	//just announce it like it's happening
	Event.kill() 		//do not process this event - no starts, no ticks, no ends
