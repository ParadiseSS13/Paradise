// Relays messages to staff
/datum/redis_callback/staff_in
	channel = "byond.staffsay"

/datum/redis_callback/staff_in/on_message(message)
	var/list/data = json_decode(message)
	if(data["source"] == GLOB.configuration.system.instance_id) // Ignore self messages
		return
	for(var/client/C in GLOB.admins)
		if(check_rights(null, FALSE, C.mob))
			to_chat(C, "<span class='staff_channel'>STAFF: <small>[data["author"]]@[data["source"]]</small>: [html_encode(data["message"])]</span>")
