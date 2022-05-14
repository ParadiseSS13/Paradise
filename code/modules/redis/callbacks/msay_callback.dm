// Relays messages to msay
/datum/redis_callback/msay_in
	channel = "byond.msay.in"

/datum/redis_callback/msay_in/on_message(message)
	var/list/data = json_decode(message)
	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN|R_MOD|R_MENTOR, FALSE, C.mob))
			to_chat(C, "<span class='mentor_channel'>MENTOR: <small>[data["author"]]@[data["source"]]</small>: [html_encode(data["message"])]</span>")

