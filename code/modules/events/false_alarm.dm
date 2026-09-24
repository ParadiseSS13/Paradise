/datum/event/falsealarm
	name = "False Alarm"
	endWhen			= 1
	var/static/list/possible_event_types = GLOB.false_alarm_types
	var/datum/event/working_event
	var/event_override

/datum/event/falsealarm/New(datum/event_meta/EM, skeleton = FALSE, _severity, override_input)
	event_override = override_input
	..()

/datum/event/falsealarm/start()
	. = ..()
	var/datum/event/working_event_type
	if(isnull(event_override))
		working_event_type = pick(possible_event_types)
	else
		working_event_type = event_override
	working_event = new working_event_type(skeleton = TRUE)
	log_debug("False alarm selecting [working_event] to imitate")

/datum/event/falsealarm/announce()
	if(working_event.fake_announce())
		return
	working_event.announce(TRUE)
	message_admins("False Alarm: [working_event]")
	kill()

/datum/event/falsealarm/end()
	QDEL_NULL(working_event)
