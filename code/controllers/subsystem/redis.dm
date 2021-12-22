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

// Redis operations
// These will be moved in the final PR
#define rustg_redis_connect(connstring) call(RUST_G, "redis_connect")(connstring)
/proc/rustg_redis_disconnect() return call(RUST_G, "redis_disconnect")()
#define rustg_redis_subscribe(channel) call(RUST_G, "redis_subscribe")(channel)
/proc/rustg_redis_get_messages() return call(RUST_G, "redis_get_messages")()
#define rustg_redis_publish(channel, message) call(RUST_G, "redis_publish")(channel, message)
#define RUST_REDIS_ERROR_CHANNEL "RUSTG_REDIS_ERROR_CHANNEL"

// SS meta procs
/datum/controller/subsystem/redis/stat_entry()
	..("S:[length(subbed_channels)] | Q:[length(queue)] | C:[connected ? "Y" : "N"]")

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
	setup_debug_callback() // TODO: Remove
	return ..()

/datum/controller/subsystem/redis/fire()
	check_messages()


// Redis integration stuff
/datum/controller/subsystem/redis/proc/connect()
	rustg_redis_connect("redis://10.0.0.10/") // MAKE A CONFIG STRING LATER YOU DONKEY
	connected = TRUE


/datum/controller/subsystem/redis/proc/disconnect()
	rustg_redis_disconnect()
	connected = FALSE


/**
  * Subscribes to a redis channel
  *
  * This proc will have the game subscribe to a channel.
  * In doing so, the callback given will then trigger with the channel events.
  * Please use this, as opposed to manually invoking rustg_redis_subscribe()
  *
  * Arguments:
  * * channel_name - Channel to subscribe to
  * * proc_callback - The callback to run when a message is receievd
  */
/datum/controller/subsystem/redis/proc/subscribe(channel_name, datum/callback/proc_callback)
	ASSERT(!isnull(channel_name))
	ASSERT(!isnull(proc_callback))

	if(!connected) // TODO: If redis is enabled in config, but we arent connected, throw a stack trace
		return

	if(channel_name in subbed_channels)
		CRASH("Attempted to subscribe to the channel '[channel_name]' twice!")

	rustg_redis_subscribe(channel_name)
	subbed_channels[channel_name] = proc_callback


/datum/controller/subsystem/redis/proc/check_messages()
	var/raw_data = rustg_redis_get_messages()
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
		// Check its an actual channel
		if(!(channel in subbed_channels))
			stack_trace("Recieved a message on the channel '[channel]' when we arent subscribed to it. What the heck?")
			continue

		var/datum/callback/CB = subbed_channels[channel]
		for(var/message in usable_data[channel])
			CB.InvokeAsync(channel, message)


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


/// Holder datum for redis messages sent before the SS is online
/datum/redis_message
	/// Destination channel for this message
	var/channel = null
	/// Message for that channel
	var/message = null


/**
  * Example of a redis callback
  *
  * The redis event SS will always send the channel the message got receievd on, as well as the message itself.
  * Any other vars will not be used.
  * Please use this proc as a copypaste template for future ones
  *
  * Arguments:
  * * channel - Channel the message is from.
  * * message - The message sent on the channel.
  */
/datum/controller/subsystem/redis/proc/debug_callback(channel, message)
	publish("aa07.debug.in", "Message received at BYOND in channel [channel] at [time_stamp()] - '[message]'") // Send a message to the debug poker


// Misc protection stuff
/datum/controller/subsystem/redis/CanProcCall(procname)
	return FALSE

/datum/controller/subsystem/redis/vv_edit_var(var_name, var_value)
	return FALSE // dont even try


// TODO: Remove
/datum/controller/subsystem/redis/proc/setup_debug_callback()
	var/datum/callback/cb = CALLBACK(src, .proc/debug_callback)
	subscribe("aa07.debug.out", cb)
