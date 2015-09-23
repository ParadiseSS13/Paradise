/client/proc/dsay(msg as text)
	set category = "Special Verbs"
	set name = "Dsay" //Gave this shit a shorter name so you only have to time out "dsay" rather than "dead say" to use it --NeoFite
	set hidden = 1
	if(!src.holder)
		src << "Only administrators may use this command."
		return
	if(!src.mob)
		return
	if(prefs.muted & MUTE_DEADCHAT)
		src << "\red You cannot send DSAY messages (muted)."
		return

	if(!(prefs.toggles & CHAT_DEAD))
		src << "\red You have deadchat muted."
		return

	if (src.handle_spam_prevention(msg,MUTE_DEADCHAT))
		return

	var/stafftype = null

	if (src.holder.rights & R_MENTOR)
		stafftype = "MENTOR"

	if (src.holder.rights & R_MOD)
		stafftype = "MOD"

	if (src.holder.rights & R_ADMIN)
		stafftype = "ADMIN"

	msg = sanitize(copytext(msg, 1, MAX_MESSAGE_LEN))
	log_admin("[key_name(src)] : [msg]")

	if (!msg)
		return

	var/prefix = "[stafftype] ([src.key])"
	if(holder.fakekey)
		prefix = "Administrator"
	say_dead_direct("<span class='name'>[prefix]</span> says, <span class='message'>\"[msg]\"</span>")

	feedback_add_details("admin_verb","D") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
