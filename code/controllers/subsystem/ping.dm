/*!
 * Copyright (c) 2022 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */
#define PING_BUFFER_TIME 25

SUBSYSTEM_DEF(ping)
	name = "Ping"
	priority = FIRE_PRIORITY_PING
	wait = 6 SECONDS
	flags = SS_NO_INIT | SS_NO_FIRE
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/currentrun = list()

/datum/controller/subsystem/ping/stat_entry()
	..("P:[GLOB.clients.len]")

/datum/controller/subsystem/ping/fire(resumed = FALSE)
	// Prepare the new batch of clients
	if (!resumed)
		src.currentrun = GLOB.clients.Copy()

	// De-reference the list for sanic speeds
	var/list/currentrun = src.currentrun

	while (currentrun.len)
		var/client/client = currentrun[currentrun.len]
		currentrun.len--
		if (!client || world.time - client.connection_time < PING_BUFFER_TIME || client.inactivity >= (wait-1))
			if (MC_TICK_CHECK)
				return
			continue
		winset(client, null, "command=.update_ping+[num2text(world.time+world.tick_lag*TICK_USAGE_REAL/100, 32)]")
		if (MC_TICK_CHECK)
			return

#undef PING_BUFFER_TIME
