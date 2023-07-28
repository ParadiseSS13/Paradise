/datum/event_container/mundane/New()
	. = ..()
	available_events |= new /datum/event_meta(EVENT_LEVEL_MUNDANE, "New Space Law",	/datum/event/new_space_law,	80, TRUE)
