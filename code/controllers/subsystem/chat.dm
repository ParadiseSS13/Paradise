SUBSYSTEM_DEF(chat)
	name = "Chat"
	flags = SS_TICKER
	wait = 0.1 SECONDS
	priority = FIRE_PRIORITY_CHAT
	init_order = INIT_ORDER_CHAT
	offline_implications = "Chat messages will no longer be cleanly queued. No immediate action is needed."
	/// Associative list (/client => /text) containing messages to be sent to the client next fire
	var/list/payload

/datum/controller/subsystem/chat/Initialize()
	LAZYINITLIST(payload)
	return ..()

/datum/controller/subsystem/chat/fire()
	if(!payload)
		return

	for(var/i in payload)
		var/client/C = i
		if(C)
			C << output(payload[C], "browseroutput:output")
		payload -= C

		if(MC_TICK_CHECK)
			return

/**
  * Queues a message to be sent to one or multiple targets next fire.
  *
  * Arguments:
  * * target - The target or (list of targets) to send the message to
  * * message - The message in HTML
  * * handle_whitespace - Whether \n and \t should be converted into HTML counterparts
  * * trailing_newline - Whether a line break should be added at the end of the message
  */
/datum/controller/subsystem/chat/proc/queue(target, message, handle_whitespace = TRUE, trailing_newline = TRUE)
	if(!target || !message)
		return

	if(!istext(message))
		stack_trace("to_chat called with invalid input type")
		return

	if(target == world)
		target = GLOB.clients

	//Some macros remain in the string even after parsing and fuck up the eventual output
	var/original_message = message
	message = replacetext(message, "\improper", "")
	message = replacetext(message, "\proper", "")
	if(handle_whitespace)
		message = replacetext(message, "\n", "<br>")
		message = replacetext(message, "\t", "[FOURSPACES][FOURSPACES]")
	if(trailing_newline)
		message += "<br>"

	//url_encode it TWICE, this way any UTF-8 characters are able to be decoded by the Javascript.
	//Do the double-encoding here to save nanoseconds
	var/twiceEncoded = url_encode(url_encode(message))
	if(islist(target))
		for(var/I in target)
			var/client/C = CLIENT_FROM_VAR(I) //Grab us a client if possible
			if(!C)
				continue

			//Send it to the old style output window.
			SEND_TEXT(C, original_message)

			if(!C?.chatOutput || C.chatOutput.broken) //A player who hasn't updated his skin file.
				continue

			if(!C.chatOutput.loaded) //Client still loading, put their messages in a queue
				C.chatOutput.messageQueue += message
				continue

			payload[C] += twiceEncoded
	else
		var/client/C = CLIENT_FROM_VAR(target) //Grab us a client if possible
		if(!C)
			return

		//Send it to the old style output window.
		SEND_TEXT(C, original_message)

		if(!C?.chatOutput || C.chatOutput.broken) //A player who hasn't updated his skin file.
			return

		if(!C.chatOutput.loaded) //Client still loading, put their messages in a queue
			C.chatOutput.messageQueue += message
			return

		payload[C] += twiceEncoded
