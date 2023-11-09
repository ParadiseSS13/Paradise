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

		src << link(GLOB.configuration.overflow.overflow_server_location)

/mob/new_player/Logout()
	. = ..()

	addtimer(CALLBACK(src, PROC_REF(reserve_queue_slot)), 10 MINUTES)

/mob/new_player/proc/reserve_queue_slot()
	if(client?.ckey in GLOB.player_list)
		return

	SSqueue.queue_bypass_list.Remove(last_known_ckey)
