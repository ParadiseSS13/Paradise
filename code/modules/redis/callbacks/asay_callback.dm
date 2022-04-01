// Relays messages to asay
/datum/redis_callback/asay_in
	channel = "byond.asay.in"

/datum/redis_callback/asay_in/on_message(message)
	var/list/data = json_decode(message)
	for(var/client/C in GLOB.admins)
		if(R_ADMIN & C.holder.rights)
			to_chat(C, "<span class='admin_channel'>ADMIN: <small>[data["author"]]@[data["source"]]</small>: [html_encode(data["message"])]</span>")
