/*!
 * Copyright (c) 2022 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

SUBSYSTEM_DEF(ping)
	name = "Ping"
	priority = FIRE_PRIORITY_PING
	wait = 4 SECONDS
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	offline_implications = "Chat ping system will no longer function correctly. No immediate action is needed."

	/// List used each time SS fires to track which clients have been processed so far
	var/list/current_run = list()

/datum/controller/subsystem/ping/stat_entry(msg)
	msg = "P:[length(GLOB.clients)]"
	return ..()

/datum/controller/subsystem/ping/fire(resumed = FALSE)
	// Prepare the new batch of clients
	if(!resumed)
		src.current_run = GLOB.clients.Copy()

	// De-reference the list for sanic speeds
	var/list/current_run = src.current_run

	while(length(current_run))
		var/client/client = current_run[length(current_run)]
		current_run.len--

		if(client?.tgui_panel?.is_ready())
			// Send a soft ping
			client.tgui_panel.window.send_message("ping/soft", list(
				// Slightly less than the subsystem timer (somewhat arbitrary)
				// to prevent incoming pings from resetting the afk state
				"afk" = client.is_afk(3.5 SECONDS),
			))

		if(MC_TICK_CHECK)
			return
