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

// SS meta procs
/datum/controller/subsystem/redis/stat_entry()
	..("S:[length(subbed_channels)] | Q:[length(queue)] | C:[connected ? "Y" : "N"]")

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

			rustg_redis_subscribe(RCB.channel)
			subbed_channels[RCB.channel] = RCB

		var/amount_registered = length(subbed_channels)
		log_startup_progress("Registered [amount_registered] callback[amount_registered == 1 ? "" : "s"].")

	return ..()

/datum/controller/subsystem/redis/fire()
	check_messages()


// Redis integration stuff
/datum/controller/subsystem/redis/proc/connect()
	if(GLOB.configuration.redis.enabled)
		var/conn_failed = rustg_redis_connect(GLOB.configuration.redis.connstring)
		if(conn_failed)
			log_startup_progress("Failed to connect to redis. Please inform the server host.")
			SEND_TEXT(world.log, "Redis connection failure: [conn_failed]")
			return

		connected = TRUE

/datum/controller/subsystem/redis/proc/disconnect()
	rustg_redis_disconnect()
	connected = FALSE

/datum/controller/subsystem/redis/proc/check_messages()
	var/raw_data = rustg_redis_get_messages()
	var/list/usable_data

	try // Did you know byond had try catch?
		usable_data = json_decode(raw_data)
	catch
		message_admins("Failed to deserialise a redis message | Please inform the server host.")
		log_debug("Redis raw data: [raw_data]")
		return

	for(var/channel in usable_data)
		if(channel == RUSTG_REDIS_ERROR_CHANNEL)
			message_admins("Redis error: [usable_data[channel]] | Please inform the server host.") // uh oh
			continue
		// Check its an actual channel
		if(!(channel in subbed_channels))
			stack_trace("Recieved a message on the channel '[channel]' when we arent subscribed to it. What the heck?")
			continue

		var/datum/redis_callback/RCB = subbed_channels[channel]
		for(var/message in usable_data[channel])
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
	rustg_redis_publish(channel, message)


// Misc protection stuff
/datum/controller/subsystem/redis/CanProcCall(procname)
	return FALSE

/datum/controller/subsystem/redis/vv_edit_var(var_name, var_value)
	return FALSE // dont even try
