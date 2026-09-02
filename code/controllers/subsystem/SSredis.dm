SUBSYSTEM_DEF(redis)
	name = "Redis"
	init_order = INIT_ORDER_REDIS
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY // ALL THE THINGS
	wait = 1
	flags = SS_TICKER // Every tick
	/// Are we connected
	var/connected = FALSE
	/// Amount of subscribed channels on the redis server
	var/list/subbed_channels = list()
	/// Message queue (If messages are sent before the SS has init'd)
	var/list/datum/redis_message/queue = list()
	offline_implications = "The server will no longer be able to send or receive redis messages. Shuttle call recommended (Potential server crash inbound)."
	cpu_display = SS_CPUDISPLAY_LOW

// SS meta procs
/datum/controller/subsystem/redis/get_stat_details()
	return "S:[length(subbed_channels)] | Q:[length(queue)] | C:[connected ? "Y" : "N"]"

/datum/controller/subsystem/redis/Initialize()
	// Connect to cappuccino
	connect()

	if(connected)
		// Loop efficiency doesnt matter here. It runs once and likely wont have any events in
		for(var/datum/redis_message/RM in queue)
			publish(RM.channel, RM.message)

		// Setup all callbacks
		for(var/cb in subtypesof(/datum/redis_callback))
			var/datum/redis_callback/RCB = new cb()
			if(isnull(RCB.channel))
				stack_trace("[RCB.type] has no channel set!")
				continue

			if(RCB.channel in subbed_channels)
				stack_trace("Attempted to subscribe to the channel '[RCB.channel]' from [RCB.type] twice!")

			rustlibs_redis_subscribe(RCB.channel)
			subbed_channels[RCB.channel] = RCB

		// Send our presence to required channels
		var/list/presence_data = list()
		presence_data["author"] = "system"
		presence_data["source"] = GLOB.configuration.system.instance_id
		presence_data["message"] = "Connected at `[SQLtime()]` during round [GLOB.round_id]"

		var/presence_text = json_encode(presence_data)

		for(var/channel in list("byond.asay", "byond.msay")) // Channels to announce to
			publish(channel, presence_text)

		// Report detailed presence info to system
		var/list/presence_data_2 = list()
		presence_data_2["source"] = GLOB.configuration.system.instance_id
		presence_data_2["round_id"] = GLOB.round_id
		presence_data_2["event"] = "server_restart"
		publish("byond.system", json_encode(presence_data_2))

		var/amount_registered = length(subbed_channels)
		log_startup_progress("Registered [amount_registered] callback[amount_registered == 1 ? "" : "s"].")

/datum/controller/subsystem/redis/fire()
	check_messages()


// Redis integration stuff
/datum/controller/subsystem/redis/proc/connect()
	if(GLOB.configuration.redis.enabled)
		#ifndef GAME_TESTS // CI uses linux so dont flag up a fail there
		if(world.system_type == UNIX)
			stack_trace("SSredis has known to be very buggy when running on Linux with random dropouts ocurring due to interrupted syscalls. You have been warned!")
		#endif

		var/conn_failed = rustlibs_redis_connect(GLOB.configuration.redis.connstring)
		if(conn_failed)
			log_startup_progress("Failed to connect to redis. Please inform the server host.")
			SEND_TEXT(world.log, "Redis connection failure: [conn_failed]")
			return

		connected = TRUE

/datum/controller/subsystem/redis/proc/disconnect()
	rustlibs_redis_disconnect()
	connected = FALSE

/datum/controller/subsystem/redis/proc/check_messages()
	var/list/data = rustlibs_redis_get_messages()

	for(var/channel in data)
		if(channel == RUSTLIBS_REDIS_ERROR_CHANNEL)
			var/redis_error_data = data[channel]
			var/error_str
			if(islist(redis_error_data))
				error_str = json_encode(redis_error_data)
			else
				error_str = redis_error_data

			message_admins("Redis error: [error_str] | Please inform the server host")
			log_game("Redis error: [error_str]")
			continue
		// Check its an actual channel
		if(!(channel in subbed_channels))
			stack_trace("Received a message on the channel '[channel]' when we arent subscribed to it. What the heck?")
			continue

		var/datum/redis_callback/RCB = subbed_channels[channel]
		for(var/message in data[channel])
			RCB.on_message(message)

/datum/controller/subsystem/redis/proc/publish(channel, message)
	// If we arent alive, queue
	if(!connected)
		var/datum/redis_message/RM = new()
		RM.channel = channel
		RM.message = message
		queue += RM
		return

	// If we are alive, publish straight away
	rustlibs_redis_publish(channel, message)


// Misc protection stuff
/datum/controller/subsystem/redis/CanProcCall(procname)
	return FALSE

/datum/controller/subsystem/redis/vv_edit_var(var_name, var_value)
	return FALSE // dont even try
