/datum/tgs_event_handler/impl/HandleEvent(event_code, ...)
	. = ..()
	if(event_code != TGS_EVENT_DEPLOYMENT_COMPLETE)
		return

	SSredis.disconnect()
	SSredis.connect()
