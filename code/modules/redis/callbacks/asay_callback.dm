// Relays messages to asay
/datum/redis_callback/asay_in
	channel = "byond.asay"

/datum/redis_callback/asay_in/on_message(message)
	var/list/data = json_decode(message)
	if(data["source"] == GLOB.configuration.system.instance_id) // Ignore self messages
		return
	for(var/client/C in GLOB.admins)
		if(R_ADMIN & C.holder.rights)
			to_chat(C, SPAN_ADMIN_CHANNEL("ADMIN: <small>[data["author"]]@[data["source"]]</small>: [html_encode(data["message"])]"))
