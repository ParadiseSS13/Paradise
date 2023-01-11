///Culling occurs when a client has not pressed a key in over 60 seconds. We stop processing their inputs until they press another key down.
#define AUTO_CULL_TIME 60 SECONDS


SUBSYSTEM_DEF(input)
	name = "Input"
	wait = 1 //SS_TICKER means this runs every tick
	flags = SS_TICKER
	init_order = INIT_ORDER_INPUT
	priority = FIRE_PRIORITY_INPUT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	offline_implications = "Player input will no longer be recognised. Immediate server restart recommended."

	/// List of clients whose input to process in loop.
	var/list/client/processing = list()

/datum/controller/subsystem/input/Initialize()
	initialized = TRUE
	refresh_client_macro_sets()
	return ..()

/datum/controller/subsystem/input/fire(resumed = FALSE)
	var/list/to_cull
	for(var/client/C in processing)
		if(processing[C] + AUTO_CULL_TIME < world.time)
			if(!length(C.input_data.keys_held))
				LAZYADD(to_cull, C)
			else
				continue // they fell asleep on their keyboard or w/e, let them
		C.key_loop()

	if(to_cull)
		processing -= to_cull

/datum/controller/subsystem/input/proc/refresh_client_macro_sets()
	var/list/clients = GLOB.clients
	for(var/i in 1 to length(clients))
		var/client/user = clients[i]
		user.set_macros()

#undef AUTO_CULL_TIME
