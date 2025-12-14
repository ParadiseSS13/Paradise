USER_VERB(dsay, R_ADMIN|R_MOD, "Dsay", "Deadsay", VERB_CATEGORY_HIDDEN, msg as text)
	if(!client.mob)
		return

	if(check_mute(client.ckey, MUTE_DEADCHAT))
		to_chat(client, SPAN_WARNING("You cannot send DSAY messages (muted)."))
		return

	if(!(client.prefs.toggles & PREFTOGGLE_CHAT_DEAD))
		to_chat(client, SPAN_WARNING("You have deadchat muted."))
		return

	if(client.handle_spam_prevention(msg, MUTE_DEADCHAT))
		return

	var/stafftype = null

	if(check_rights(R_MENTOR, 0))
		stafftype = "MENTOR"

	if(check_rights(R_DEV_TEAM, 0))
		stafftype = "DEVELOPER"

	if(check_rights(R_MOD, 0))
		stafftype = "MOD"

	if(check_rights(R_ADMIN, 0))
		stafftype = "ADMIN"

	msg = emoji_parse(sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN)))
	log_admin("[key_name(client)] : [msg]")

	if(!msg)
		return

	var/prefix = "[stafftype] ([client.key])"
	if(client.holder.fakekey)
		prefix = "Administrator"
	say_dead_direct(SPAN_NAME("[prefix]</span> says, <span class='message'>\"[msg]\""))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Dsay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
