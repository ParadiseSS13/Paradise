/**
  * # Redis callback
  *
  * Callback datum for subscribed redis channel handling
  *
  * This datum is used for easily assigning callbacks for SSredis to use
  * when a message is receievd on a channel. Define a channel on the `channel`
  * var and SSredis will automatically register subtypes of [/datum/redis_callback]
  */
/datum/redis_callback
	/// Channel for this callback to listen on
	var/channel = null

/**
  * Message handler callback
  *
  * This callback is ran when a message is received on the assigned channel.
  * Make sure you override it on subtypes or it wont work.
  *
  * Arguments:
  * * message - The message received on the redis channel
  */
/datum/redis_callback/proc/on_message(message)
	CRASH("on_message() not overridden for [type]!")

// Misc protections
/datum/redis_callback/vv_edit_var(var_name, var_value)
	return FALSE // no

/datum/redis_callback/CanProcCall(procname)
	return FALSE // no
