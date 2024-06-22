/datum/tgs_event_handler/impl/HandleEvent(event_code, ...)
	. = ..()
	SSredis.disconnect()
	SSredis.connect()
