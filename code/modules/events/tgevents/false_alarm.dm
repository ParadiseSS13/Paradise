/datum/event/falsealarm
	announceWhen	= 0
	endWhen			= 1

/datum/event/falsealarm/announce()
		var/datum/event/E = pick(possibleEvents)
		var/datum/event/Event = new E
		message_admins("False Alarm: [Event]")
		Event.announce() 	//just announce it like it's happening
		Event.kill() 		//do not process this event - no starts, no ticks, no ends
