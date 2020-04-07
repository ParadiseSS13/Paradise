/client/proc/dsay(msg as text)
	set category = "Admin"
	set name = "Dsay" //Gave this shit a shorter name so you only have to time out "dsay" rather than "dead say" to use it --NeoFite
	set hidden = 1
	
	if(!check_rights(R_ADMIN|R_MOD))
		return
		
	if(!src.mob)
		return
		
	if(prefs.muted & MUTE_DEADCHAT)
		to_chat(src, "<span class='warning'>You cannot send DSAY messages (muted).</span>")
		return

	if(!(prefs.toggles & CHAT_DEAD))
		to_chat(src, "<span class='warning'>You have deadchat muted.</span>")
		return

	if(handle_spam_prevention(msg,MUTE_DEADCHAT))
		return

	var/stafftype = null

	if(check_rights(R_MENTOR, 0))
		stafftype = "MENTOR"

	if(check_rights(R_MOD, 0))
		stafftype = "MOD"

	if(check_rights(R_ADMIN, 0))
		stafftype = "ADMIN"

	msg = sanitize(copytext(msg, 1, MAX_MESSAGE_LEN))
	log_admin("[key_name(src)] : [msg]")

	if(!msg)
		return

	var/prefix = "[stafftype] ([src.key])"
	if(holder.fakekey)
		prefix = "Administrator"
	say_dead_direct("<span class='name'>[prefix]</span> says, <span class='message'>\"[msg]\"</span>")

	feedback_add_details("admin_verb","D") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/get_dead_say()
	var/msg = input(src, null, "dsay \"text\"") as text
	dsay(msg)
