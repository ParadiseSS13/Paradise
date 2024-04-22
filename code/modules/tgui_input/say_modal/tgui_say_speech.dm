/**
 * Delegates the speech to the proper channel.
 *
 * Arguments:
 * 	entry - the text to broadcast
 * 	channel - the channel to broadcast in
 * Returns:
 *  boolean - on success or failure
 */
/datum/tgui_say/proc/delegate_speech(entry, channel)
	switch(channel)
		if(SAY_CHANNEL)
			client.mob.say_verb(entry)
			return TRUE
		if(RADIO_CHANNEL)
			client.mob.say_verb((isliving(client.mob) ? ";" : "") + entry)
			return TRUE
		if(WHISPER_CHANNEL)
			client.mob.whisper(entry)
			return TRUE
		if(ME_CHANNEL)
			client.mob.me_verb(entry)
			return TRUE
		if(OOC_CHANNEL)
			client.ooc(entry)
			return TRUE
		if(LOOC_CHANNEL)
			client.looc(entry)
			return TRUE
		if(ADMIN_CHANNEL)
			client.cmd_admin_say(entry)
			return TRUE
		if(MENTOR_CHANNEL)
			client.cmd_mentor_say(entry)
			return TRUE
		if(DSAY_CHANNEL)
			client.dsay(entry)
			return TRUE
	return FALSE

/**
 * Handles text entry and forced speech.
 *
 * Arguments:
 *  payload - a string list containing entry & channel
 * Returns:
 *  boolean - success or failure
 */
/datum/tgui_say/proc/handle_entry(payload)
	if(!payload?["channel"] || !payload["entry"])
		var/hacker_man_ckey = usr.client.ckey
		qdel(usr.client)
		message_admins("[hacker_man_ckey] was kicked for attemping to send a null message to TGUI-say.")
		CRASH("[hacker_man_ckey] entered in a null payload to the chat window.")
	if(length_char(payload["entry"]) > MAX_MESSAGE_LEN)
		var/hacker_man_ckey = usr.client.ckey
		qdel(usr.client)
		message_admins("[hacker_man_ckey] was kicked for attemping to bypass TGUI-say character limits.")
		CRASH("[hacker_man_ckey] has entered more characters than allowed into a TGUI-Say.")
	delegate_speech(payload["entry"], payload["channel"])
	return TRUE
