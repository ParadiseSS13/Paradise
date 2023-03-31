/**
  * # Redis message
  *
  * Holder datum for redis messages
  *
  * This datum is used for caching messages that SSredis tries to
  * publish before it has connected. It is not used for any subscribed
  * channel handling.
  */
/datum/redis_message
	/// Destination channel for this message
	var/channel = null
	/// Message for that channel
	var/message = null
