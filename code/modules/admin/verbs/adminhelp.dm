/client/verb/adminhelp()
	set category = "Admin"
	set name = "Adminhelp"

	//handle muting and automuting
	if(check_mute(ckey, MUTE_ADMINHELP))
		to_chat(src, "<font color='red'>Error: Admin-PM: You cannot send adminhelps (Muted).</font>", MESSAGE_TYPE_ADMINPM, confidential = TRUE)
		return

	var/msg
	var/list/type = list("Mentorhelp", "Adminhelp")
	var/selected_type = input("Pick a category.", "Admin Help") as null|anything in type
	if(selected_type)
		msg = clean_input("Please enter your message.", selected_type)

	if(!msg)
		return

	if(handle_spam_prevention(msg, MUTE_ADMINHELP, OOC_COOLDOWN))
		return

	msg = sanitize_simple(copytext_char(msg, 1, MAX_MESSAGE_LEN))
	if(!msg) // No message after sanitisation
		return

	var/span_type
	var/message_type
	var/datum/ticket/T
	if(selected_type == "Mentorhelp")
		T = SSmentor_tickets.newHelpRequest(src, msg) // Mhelp
		span_type = "mentorhelp"
		message_type = MESSAGE_TYPE_MENTORPM
		//show it to the person mentorhelping too
		to_chat(src, chat_box_mhelp("<span class='[span_type]'><b>[selected_type]</b><br><br>[msg]</span>"), message_type, confidential = TRUE)
	else
		T = SStickets.newHelpRequest(src, msg) // Ahelp
		span_type = "adminhelp"
		message_type = MESSAGE_TYPE_ADMINPM
		//show it to the person adminhelping too
		to_chat(src, chat_box_ahelp("<span class='[span_type]'><b>[selected_type]</b><br><br>[msg]</span>"), message_type, confidential = TRUE)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Adminhelp") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	switch(selected_type)
		if("Adminhelp")
			//See how many staff are on
			var/list/admincount = staff_countup(R_BAN)
			var/active_admins = admincount[1]

			log_admin("[selected_type]: [key_name(src)]: [msg] - heard by [active_admins] non-AFK admins.")
			GLOB.discord_manager.send2discord_simple_noadmins("**\[Adminhelp]** Ticket [T.ticketNum], [key_name(src)]: [msg]", check_send_always = TRUE)

		if("Mentorhelp")
			var/list/mentorcount = staff_countup(R_MENTOR)
			var/active_mentors = mentorcount[1]

			log_admin("[selected_type]: [key_name(src)]: [msg] - heard by [active_mentors] non-AFK mentors.")
			GLOB.discord_manager.send2discord_simple_mentor("Ticket [T.ticketNum], [key_name(src)]: [msg]")
