// Just dumps the text in the admin chat box
/datum/world_topic_handler/gsay
	topic_key = "gsay"
	requires_commskey = TRUE

/datum/world_topic_handler/gsay/execute(list/input, key_valid)
	if(!input["msg"] || !input["usr"] || !input["src"])
		return json_encode(list("error" = "Malformed request"))

	var/message = input["msg"]
	var/user = input["usr"]
	var/source = input["src"]

	// Send to online admins
	for(var/client/C in GLOB.admins)
		if(R_ADMIN & C.holder.rights)
			to_chat(C, "<span class='admin_channel'>GSAY: [user]@[source]: [message]</span>")

