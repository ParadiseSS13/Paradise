SUBSYSTEM_DEF(chat)
	name = "Chat"
	flags = SS_TICKER|SS_NO_INIT
	wait = 1
	priority = FIRE_PRIORITY_CHAT
	init_order = INIT_ORDER_CHAT

	var/list/payload = list()


/datum/controller/subsystem/chat/fire()
	for(var/i in payload)
		var/client/C = i
		C << output(payload[C], "browseroutput:output")
		payload -= C

		if(MC_TICK_CHECK)
			return


/datum/controller/subsystem/chat/proc/queue(target, message, flag)
	if(!target || !message)
		return

	if(!istext(message))
		stack_trace("to_chat called with invalid input type")
		return

	if(target == world)
		target = GLOB.clients

	//Some macros remain in the string even after parsing and fuck up the eventual output
	message = replacetext(message, "\improper", "")
	message = replacetext(message, "\proper", "")
	message += "<br>"


	//url_encode it TWICE, this way any UTF-8 characters are able to be decoded by the Javascript.
	//Do the double-encoding here to save nanoseconds
	var/twiceEncoded = url_encode(url_encode(message))

	if(islist(target))
		for(var/I in target)
			var/client/C = CLIENT_FROM_VAR(I) //Grab us a client if possible

			if(!C?.chatOutput || C.chatOutput.broken) //A player who hasn't updated his skin file.
				continue

			if(!C.chatOutput.loaded) //Client still loading, put their messages in a queue
				C.chatOutput.messageQueue += message
				continue

			payload[C] += twiceEncoded

	else
		var/client/C = CLIENT_FROM_VAR(target) //Grab us a client if possible

		if(!C?.chatOutput || C.chatOutput.broken) //A player who hasn't updated his skin file.
			return

		if(!C.chatOutput.loaded) //Client still loading, put their messages in a queue
			C.chatOutput.messageQueue += message
			return

		payload[C] += twiceEncoded