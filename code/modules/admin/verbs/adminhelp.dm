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

	//show it to the person adminhelping too
	to_chat(src, "<span class='boldnotice'>[selected_type]</b>: [msg]</span>")
	feedback_add_details("admin_verb","AH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	switch(selected_type)
		if("Adminhelp")
			//See how many staff are on
			var/list/admincount = staff_countup(R_BAN)
			var/active_admins = admincount[1]

			log_admin("[selected_type]: [key_name(src)]: [msg] - heard by [active_admins] non-AFK admins.")
			SSdiscord.send2discord_simple_noadmins("[selected_type] from [key_name(src)]: [msg]", check_send_always = TRUE)

		if("Mentorhelp")
			var/alerttext
			var/list/mentorcount = staff_countup(R_MENTOR)
			var/active_mentors = mentorcount[1]
			var/inactive_mentors = mentorcount[3]

			if(active_mentors <= 0)
				if(inactive_mentors > 0)
					alerttext = " | **ALL MENTORS AFK**"
				else
					alerttext = " | **NO MENTORS ONLINE**"

			log_admin("[selected_type]: [key_name(src)]: [msg] - heard by [active_mentors] non-AFK mentors.")
			SSdiscord.send2discord_simple(DISCORD_WEBHOOK_MENTOR, "[key_name(src)]: [msg][alerttext]")
