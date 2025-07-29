/// Will our restart be slower?
GLOBAL_VAR_INIT(slower_restart, FALSE)

/proc/server_announce_global(announcement_text)
	to_chat(world, "<span style='color: #ff00ff'>\[Server] [announcement_text]</span>")

/proc/server_announce_adminonly(announcement_text)
	to_chat(GLOB.admins, "<span style='color: #ff00ff'>\[Server] \[Admin] [announcement_text]</span>")

/datum/tgs_event_handler/impl
	var/datum/timedevent/reattach_timer

	receive_health_checks = TRUE

/datum/tgs_event_handler/impl/HandleEvent(event_code, ...)
	// Do this for any TGS event receieved as deployments dont proc the heartbeat event
	SSheartbeat.last_heartbeat = REALTIMEOFDAY

	switch(event_code)
		if(TGS_EVENT_REBOOT_MODE_CHANGE)
			var/list/reboot_mode_lookup = list ("[TGS_REBOOT_MODE_NORMAL]" = "be normal", "[TGS_REBOOT_MODE_SHUTDOWN]" = "shutdown the server", "[TGS_REBOOT_MODE_RESTART]" = "hard restart the server")
			var/old_reboot_mode = args[2]
			var/new_reboot_mode = args[3]
			if(new_reboot_mode == TGS_REBOOT_MODE_SHUTDOWN)
				GLOB.slower_restart = TRUE
			else
				GLOB.slower_restart = FALSE
			server_announce_adminonly("\[Info] Reboot will no longer [reboot_mode_lookup["[old_reboot_mode]"]], it will instead [reboot_mode_lookup["[new_reboot_mode]"]]")
		if(TGS_EVENT_PORT_SWAP)
			server_announce_adminonly("\[Info] Changing port from [world.port] to [args[2]]")
		if(TGS_EVENT_INSTANCE_RENAMED)
			server_announce_adminonly("\[Info] Instance renamed to from [world.TgsInstanceName()] to [args[2]]")
		if(TGS_EVENT_COMPILE_START)
			server_announce_adminonly("\[Info] Code deployment started, new game version incoming next round...")
		if(TGS_EVENT_COMPILE_CANCELLED)
			server_announce_adminonly("\[Warning] Code deployment cancelled! Consult a headcoder/host to see if this was intentional!")
		if(TGS_EVENT_COMPILE_FAILURE)
			server_announce_adminonly("\[Error] Code deployment failed! Inform a headcoder/host immediately!")
		if(TGS_EVENT_DEPLOYMENT_COMPLETE)
			server_announce_adminonly("\[Info] Code deployment complete!")
			server_announce_global("Server update complete. Changes will be applied on the next round.")
		if(TGS_EVENT_WATCHDOG_DETACH)
			server_announce_adminonly("\[Info] Server manager restarting...")
			reattach_timer = addtimer(CALLBACK(src, PROC_REF(LateOnReattach)), 1 MINUTES, TIMER_STOPPABLE)
		if(TGS_EVENT_WATCHDOG_REATTACH)
			var/datum/tgs_version/old_version = world.TgsVersion()
			var/datum/tgs_version/new_version = args[2]
			if(!old_version.Equals(new_version))
				server_announce_adminonly("\[Info] Server manager back online. TGS has been updated to v[new_version.deprefixed_parameter]")
			else
				server_announce_adminonly("\[Info] Server manager back online")
			if(reattach_timer)
				deltimer(reattach_timer)
				reattach_timer = null
		if(TGS_EVENT_HEALTH_CHECK)
			return // does no extra behaviour

/datum/tgs_event_handler/impl/proc/LateOnReattach()
	server_announce_adminonly("\[Warning] TGS hasn't notified us of it coming back for a full minute! Is there a problem?")
