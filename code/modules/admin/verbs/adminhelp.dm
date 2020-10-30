

//This is a list of words which are ignored by the parser when comparing message contents for names. MUST BE IN LOWER CASE!
GLOBAL_LIST_INIT(adminhelp_ignored_words, list("unknown","the","a","an","of","monkey","alien","as"))

/client/verb/adminhelp()
	set category = "Admin"
	set name = "Adminhelp"

	//handle muting and automuting
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<font color='red'>Error: Admin-PM: You cannot send adminhelps (Muted).</font>")
		return

	adminhelped = 1 //Determines if they get the message to reply by clicking the name.

	var/msg
	var/list/type = list("Mentorhelp","Adminhelp")
	var/selected_type = input("Pick a category.", "Admin Help", null, null) as null|anything in type
	if(selected_type)
		msg = clean_input("Please enter your message.", "Admin Help", null)

	//clean the input msg
	if(!msg)
		return

	if(handle_spam_prevention(msg, MUTE_ADMINHELP, OOC_COOLDOWN))
		return

	msg = sanitize_simple(copytext(msg,1,MAX_MESSAGE_LEN))
	if(!msg)	return
	if(selected_type == "Mentorhelp")
		SSmentor_tickets.newHelpRequest(src, msg)
	else
		SStickets.newHelpRequest(src, msg)

	//See how many staff are on
	var/admin_number_afk = 0
	var/list/mentorholders = list()
	var/list/modholders = list()
	var/list/adminholders = list()
	for(var/client/X in GLOB.admins)
		if(check_rights(R_ADMIN, 0, X.mob))
			if(X.is_afk())
				admin_number_afk++
			adminholders += X
			continue
		if(check_rights(R_MOD, 0, X.mob))
			modholders += X
			continue
		if(check_rights(R_MENTOR, 0, X.mob))
			mentorholders += X
			continue

	//show it to the person adminhelping too
	to_chat(src, "<span class='boldnotice'>[selected_type]</b>: [msg]</span>")

	var/admin_number_present = adminholders.len - admin_number_afk
	log_admin("[selected_type]: [key_name(src)]: [msg] - heard by [admin_number_present] non-AFK admins.")
	SSdiscord.send2discord_simple_noadmins("[selected_type] from [key_name(src)]: [msg]", check_send_always = TRUE)
	feedback_add_details("admin_verb","AH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return
