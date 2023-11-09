/mob/new_player/Login()
	. = ..()

	if(!SSdbcore.IsConnected())
		return

	if(SSqueue.queue_enabled)
		if(client?.ckey in SSqueue.queue_bypass_list)
			return

		if(client?.holder)
			SSqueue.queue_bypass_list |= ckey
			return

		if(length(GLOB.clients) < SSqueue.queue_threshold)
			SSqueue.queue_bypass_list |= ckey
			return

		src << link("byond://[GLOB.configuration.overflow.overflow_server_location]")

/mob/new_player/Logout()
	. = ..()

	addtimer(CALLBACK(SSqueue, TYPE_PROC_REF(/datum/controller/subsystem/queue, reserve_queue_slot), last_known_ckey), 10 MINUTES)


/datum/controller/subsystem/queue/proc/reserve_queue_slot(reserved_ckey)
	if(reserved_ckey in GLOB.player_list)
		return

	queue_bypass_list.Remove(reserved_ckey)
