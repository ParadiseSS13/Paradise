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
	// remove this when the PR is deemed stable
	var/last_send = 0

// Redis operations
// These will be moved in the final PR
#define rustg_redis_connect(connstring) call(RUST_G, "redis_connect")(connstring)
#define rustg_redis_disconnect call(RUST_G, "redis_disconnect")()
#define rustg_redis_subscribe(channel) call(RUST_G, "redis_subscribe")(channel)
#define rustg_redis_get_messages call(RUST_G, "redis_get_messages")()
#define rustg_redis_publish(channel, message) call(RUST_G, "redis_publish")(channel, message)
#define RUST_REDIS_ERROR_CHANNEL "RUSTG_REDIS_ERROR_CHANNEL"

/datum/controller/subsystem/redis/stat_entry()
	..("S:[length(subbed_channels)] | Q:[length(queue)]")

/datum/controller/subsystem/redis/Initialize()
	if(world.system_type == UNIX)
		flags |= SS_NO_FIRE
		return ..() // Hack to bypass CI in debug mode
	// Connect to cappuccino
	connect()
	if(connected)
		// Loop efficiency doesnt matter here. It runs once and likely wont have any events in
		for(var/datum/redis_message/RM in queue)
			publish(RM.channel, RM.message)

	// Subscribe to the debug send
	subscribe("aa07.out.debug")
	return ..()

/datum/controller/subsystem/redis/fire()
	check_messages()
	// remove when PR deemed stable
	if(last_send < world.time)
		last_send = world.time + 30 SECONDS
		// Send off a message
		publish("aa07.in.debug", "Message from BYOND at [time_stamp()]") // Send a message in 8601

/datum/controller/subsystem/redis/proc/connect()
	rustg_redis_connect("redis://10.0.0.10/") // MAKE A CONFIG STRING LATER YOU DONKEY
	connected = TRUE

/datum/controller/subsystem/redis/proc/disconnect()
	rustg_redis_disconnect
	connected = FALSE

/datum/controller/subsystem/redis/proc/subscribe(channel_name)
	if(!connected)
		return
	rustg_redis_subscribe(channel_name)
	subbed_channels += channel_name

/datum/controller/subsystem/redis/proc/check_messages()
	var/raw_data = rustg_redis_get_messages
	var/list/usable_data

	try // Did you know byond had try catch?
		usable_data = json_decode(raw_data)
	catch
		message_admins("REDIS DATA DESERIALIZATION FAILED. INFORM AA07 IMMEDIATELY.")
		log_debug("REDIS RAW DATA: [raw_data]")
		return

	for(var/channel in usable_data)
		if(channel == RUST_REDIS_ERROR_CHANNEL)
			message_admins("Redis error: [usable_data[channel]] | Inform AA07") // uh oh
			continue
		for(var/message in usable_data[channel])
			log_debug("\[[channel]] [message]") // This will be cleaned up when the PR is done

/datum/controller/subsystem/redis/proc/publish(channel, message)
	if(!connected)
		var/datum/redis_message/RM = new()
		RM.channel = channel
		RM.message = message
		queue += RM
		return

	// If we are alive, publish straight away
	rustg_redis_publish(channel, message)

/// Holder datum for redis messages
/datum/redis_message
	/// Destination channel for this message
	var/channel = null
	/// Message for that channel
	var/message = null

