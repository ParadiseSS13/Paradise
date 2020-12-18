/datum/world_topic_handler
	/// Key which invokes this topic
	var/topic_key
	/// Set this to TRUE if the topic handler needs an authorised comms key
	var/requires_commskey = FALSE


/**
  * Invokes the world/Topic handler
  *
  * This includes sanity checking for if the key is required, as well as other sanity checks
  * DO NOT OVERRIDE
  * Arguments:
  * * input - The list of topic data, sent from [world/Topic]
  */
/datum/world_topic_handler/proc/invoke(list/input)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/authorised = (config.comms_password && input["key"] == config.comms_password) // No password means no comms, not any password
	if(requires_commskey && !authorised)
		// Try keep all returns in JSON unless absolutely necessary (?ping for example)
		return(json_encode(list("error" = "Invalid Key")))

	return execute(input, authorised)

/**
  * Actually executes the user's topic
  *
  * Override this to do your work in subtypes of this topic
  *
  * Arguments:
  * * input - The list of topic data, sent from [world/Topic]
  * * key_valid - Has the user entered the correct auth key
  */
/datum/world_topic_handler/proc/execute(list/input, key_valid = FALSE)
	CRASH("execute() not implemented/overridden for [type]")
