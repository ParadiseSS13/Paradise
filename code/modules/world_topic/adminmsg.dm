/datum/world_topic_handler/adminmsg
	topic_key = "adminmsg"
	requires_commskey = TRUE

/datum/world_topic_handler/adminmsg/execute(list/input, key_valid)
	/*
	We got an adminmsg from the Discord bot, so lets split the input then validate the input. Expected output:
		1. adminmsg = ckey of person the message is to
		2. msg = contents of message, params2list requires
		3. sender = the discord name that send the message.
	*/

	var/client/C

	for(var/client/K in GLOB.clients)
		if(K.ckey == input["adminmsg"])
			C = K
			break
	if(!C)
		return json_encode(list("error" = "No client with that name on server"))

	var/message =	"<font color='red'>Discord PM from <b><a href='?discord_msg=1'>[input["sender"]]</a></b>: [input["msg"]]</font>"
	var/amessage =  "<font color='blue'>Discord PM from <a href='?discord_msg=1'>[input["sender"]]</a> to <b>[key_name_admin(C)]</b>: [input["msg"]]</font>"

	// THESE TWO VARS DO VERY DIFFERENT THINGS. DO NOT ATTEMPT TO COMBINE THEM
	C.received_discord_pm = world.time
	C.last_discord_pm_time = 0

	SEND_SOUND(C, 'sound/effects/adminhelp.ogg')
	to_chat(C, message)

	for(var/client/A in GLOB.admins)
		// GLOB.admins includes anyone with a holder datum (mentors too). This makes sure only admins see ahelps
		if(check_rights(R_ADMIN, FALSE, A.mob))
			if(A != C)
				to_chat(A, amessage)

	return json_encode(list("success" = "Message Successful"))
