#define WORLD_TOPIC_STRIKES_THRESHOLD 5
#define WORLD_TOPIC_LOCKOUT_TIME 1 MINUTES

/datum/world_topic_spam_prevention_handler
	/// Amount of strikes. [WORLD_TOPIC_STRIKES_THRESHOLD] strikes is a lockout of [WORLD_TOPIC_LOCKOUT_TIME]
	var/strikes = 0
	/// Time of last request
	var/last_request = 0
	/// Is this IP currently locked out
	var/locked_out = FALSE
	/// Unlock time
	var/unlock_time = 0

/**
  * Lockout handler
  *
  * Updates strikes and timers of the most recent client to topic the server
  * including any relevant detail
  */
/datum/world_topic_spam_prevention_handler/proc/check_lockout()
	// Check if they are already locked out
	if(locked_out && (unlock_time >= world.time))
		// Relock out for another minute if youre spamming
		unlock_time = world.time + WORLD_TOPIC_LOCKOUT_TIME
		return TRUE

	// If they were locked out and are now allowed, unlock them
	if(locked_out && (unlock_time < world.time))
		strikes = 0
		locked_out = FALSE

	// Allow a grace period of 0.5 seconds per topic, or you get a strike
	if(last_request + 5 > world.time)
		strikes++
		if(strikes >= WORLD_TOPIC_STRIKES_THRESHOLD)
			locked_out = TRUE
			unlock_time = world.time + WORLD_TOPIC_LOCKOUT_TIME
			return TRUE

	// If we got here, assume they arent locked out
	last_request = world.time
	return FALSE

/*

Uncomment this if you modify the topic limiter, trust me, youll need to test it

/client/verb/debug_limiter()
	if(!GLOB.world_topic_spam_prevention_handlers[address])
		GLOB.world_topic_spam_prevention_handlers[address] = new /datum/world_topic_spam_prevention_handler

	var/datum/world_topic_spam_prevention_handler/sph = GLOB.world_topic_spam_prevention_handlers[address]
	var/result = sph.check_lockout()
	to_chat(usr, "Strikes: [sph.strikes]")
	to_chat(usr, "Last request: [sph.last_request]")
	to_chat(usr, "Locked out: [sph.locked_out]")
	to_chat(usr, "Unlock time: [sph.unlock_time]")
	to_chat(usr, "SPH Result: [result]")
	to_chat(usr, "World.time: [world.time]")
	to_chat(usr, "LR DIFF: [(sph.last_request - world.time)/10]s")
	to_chat(usr, "LO DIFF: [(sph.unlock_time - world.time)/10]s")
	to_chat(usr, "<hr>")
*/
