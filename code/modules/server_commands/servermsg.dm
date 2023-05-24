/**
  * # Server Command
  *
  * Datum to handle both sending and receiving of server commands
  *
  * This datum is an extension of the redis callback and is designed for tighter integration with the BYOND servers.
  * This list is registered and managed by SSintancing, not SSredis.
  * NOTE: These commands are "fire and forget". If you need specific data from each server, use world/Topic still
  */
/datum/server_command
	/// Does the sending server want to ignore this command? This is almost always yes unless you are doing testing stuff
	var/ignoreself = TRUE
	/// The source BYOND server for this message
	var/source = null
	/// The command name (must be unique)
	var/command_name = null
	/// Associative list of command args
	var/list/command_args = list()

/datum/server_command/proc/execute(source, command_args)
	CRASH("execute(source, command_args) not overridden for [type]!")

/datum/server_command/proc/dispatch(command_args)
	SHOULD_NOT_OVERRIDE(TRUE) // No messing with

	// Aight get serializing
	var/list/serializeable_data = list()
	serializeable_data["src"] = GLOB.configuration.system.instance_id
	serializeable_data["cmd"] = command_name
	serializeable_data["args"] = command_args

	var/payload = json_encode(serializeable_data)

	SSredis.publish(SERVER_MESSAGES_REDIS_CHANNEL, payload)

// Override this if you want a cleaner method for putting together dispatch args
/datum/server_command/proc/custom_dispatch()
	CRASH("custom_dispatch() not overridden for [type]!")
