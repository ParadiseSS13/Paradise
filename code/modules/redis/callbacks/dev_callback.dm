// Relays messages to developer
/datum/redis_callback/developer_in
	channel = "byond.devsay"

/datum/redis_callback/developer_in/on_message(message)
	var/list/data = json_decode(message)
	if(data["source"] == GLOB.configuration.system.instance_id) // Ignore self messages
		return
	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN|R_DEV_TEAM, FALSE, C.mob))
			to_chat(C, "<span class='dev_channel'>DEV: <small>[data["author"]]@[data["source"]]</small>: [html_encode(data["message"])]</span>")
