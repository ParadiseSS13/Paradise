/datum/world_topic_handler/queue_bypass
	topic_key = "queue_bypass"
	requires_commskey = TRUE

/datum/world_topic_handler/queue_bypass/execute(list/input, key_valid)
	var/ckey_check = input["ckey_check"]

	if(!ckey_check)
		return json_encode(list("error" = "No ckey supplied"))

	var/list/output_data = list()
	output_data["queue_enabled"] = SSqueue.queue_enabled

	if(SSqueue.queue_enabled)
		SSqueue.queue_bypass_list |= ckey_check

	return json_encode(output_data)
