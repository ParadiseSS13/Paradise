// Relays messages to msay
/datum/redis_callback/msay_in
	channel = "byond.msay"

/datum/redis_callback/msay_in/on_message(message)
	var/list/data = json_decode(message)
	if(data["source"] == GLOB.configuration.system.instance_id) // Ignore self messages
		return
	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN|R_MOD|R_MENTOR, FALSE, C.mob))
			to_chat(C, SPAN_MENTOR_CHANNEL("MENTOR: <small>[data["author"]]@[data["source"]]</small>: [html_encode(data["message"])]"))

