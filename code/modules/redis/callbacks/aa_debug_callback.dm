// Remove when PR is ready for merge
/datum/redis_callback/aa_debug
	channel = "aa07.debug.out"

/datum/redis_callback/aa_debug/on_message(message)
	SSredis.publish("aa07.debug.in", "Message received at BYOND in channel [channel] at [time_stamp()] - '[message]'") // Send a message to the debug poker
