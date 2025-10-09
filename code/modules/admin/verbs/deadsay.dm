ADMIN_VERB(dsay, R_ADMIN|R_MOD, "Dsay", "Deadsay", VERB_CATEGORY_HIDDEN, msg as text)
	if(!check_rights(R_ADMIN|R_MOD))
		return

	if(!user.mob)
		return

	if(check_mute(user.ckey, MUTE_DEADCHAT))
		to_chat(src, "<span class='warning'>You cannot send DSAY messages (muted).</span>")
		return

	if(!(user.prefs.toggles & PREFTOGGLE_CHAT_DEAD))
		to_chat(src, "<span class='warning'>You have deadchat muted.</span>")
		return

	if(user.handle_spam_prevention(msg, MUTE_DEADCHAT))
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
	log_admin("[key_name(src)] : [msg]")

	if(!msg)
		return

	var/prefix = "[stafftype] ([user.key])"
	if(user.holder.fakekey)
		prefix = "Administrator"
	say_dead_direct("<span class='name'>[prefix]</span> says, <span class='message'>\"[msg]\"</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Dsay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
