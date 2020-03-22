

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
	var/original_msg = msg

	//explode the input msg into a list
	var/list/msglist = splittext(msg, " ")

	//generate keywords lookup
	var/list/surnames = list()
	var/list/forenames = list()
	var/list/ckeys = list()
	for(var/mob/M in GLOB.mob_list)
		var/list/indexing = list(M.real_name, M.name)
		if(M.mind)	indexing += M.mind.name

		for(var/string in indexing)
			var/list/L = splittext(string, " ")
			var/surname_found = 0
			//surnames
			for(var/i=L.len, i>=1, i--)
				var/word = ckey(L[i])
				if(word)
					surnames[word] = M
					surname_found = i
					break
			//forenames
			for(var/i=1, i<surname_found, i++)
				var/word = ckey(L[i])
				if(word)
					forenames[word] = M
			//ckeys
			ckeys[M.ckey] = M

	var/ai_found = 0
	msg = ""
	var/list/mobs_found = list()
	for(var/original_word in msglist)
		var/word = ckey(original_word)
		if(word)
			if(!(word in GLOB.adminhelp_ignored_words))
				if(word == "ai")
					ai_found = 1
				else
					var/mob/found = ckeys[word]
					if(!found)
						found = surnames[word]
						if(!found)
							found = forenames[word]
					if(found)
						if(!(found in mobs_found))
							mobs_found += found
							if(!ai_found && isAI(found))
								ai_found = 1
							msg += "<b><font color='black'>[original_word] </font></b> "
							continue
			msg += "[original_word] "

	if(!mob)	return						//this doesn't happen

	//send this msg to all admins
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
	var/ticketNum // Holder for the ticket number
	var/prunedmsg ="[src]: [msg]" // Message without links
	var/datum/ticket/T
	var/isMhelp = selected_type == "Mentorhelp"
	var/span
	if(isMhelp)
		span = "<span class='mentorhelp'>"
		if(SSmentor_tickets.checkForOpenTicket(src)) // If user already has an open ticket
			T = SSmentor_tickets.checkForOpenTicket(src)
		else
			ticketNum = SSmentor_tickets.getTicketCounter() // ticketNum is the ticket ready to be assigned.
	else //Ahelp
		span = "<span class='adminhelp'>"
		if(SStickets.checkForOpenTicket(src)) // If user already has an open ticket
			T = SStickets.checkForOpenTicket(src) // Make T equal to the ticket they have open
		else
			ticketNum = SStickets.getTicketCounter() // ticketNum is the ticket ready to be assigned.

	if(T)
		ticketNum = T.ticketNum // ticketNum is the number of their ticket.
		T.addResponse(src, msg)

	msg = "[span][selected_type]: </span><span class='boldnotice'>[key_name(src, TRUE, selected_type)] ([ADMIN_QUE(mob,"?")]) ([ADMIN_PP(mob,"PP")]) ([ADMIN_VV(mob,"VV")]) ([ADMIN_TP(mob,"TP")]) ([ADMIN_SM(mob,"SM")]) ([admin_jump_link(mob)]) (<A HREF='?_src_=holder;[isMhelp ? "openmentorticket" : "openadminticket"]=[ticketNum]'>TICKET</A>) [ai_found ? "(<A HREF='?_src_=holder;adminchecklaws=[mob.UID()]'>CL</A>)" : ""] (<A HREF='?_src_=holder;take_question=[ticketNum][isMhelp ? ";is_mhelp=1" : ""]'>TAKE</A>) (<A HREF='?_src_=holder;resolve=[ticketNum][isMhelp ? ";is_mhelp=1" : ""]'>RESOLVE</A>) [isMhelp ? "" : "<A HREF='?_src_=holder;autorespond=[ticketNum]'>(AUTO)</A>"]  :</span> [span][msg]</span>"
	if(isMhelp)
		//Open a new adminticket and inform the user.
		SSmentor_tickets.newTicket(src, prunedmsg, msg)
		for(var/client/X in mentorholders + modholders + adminholders)
			if(X.prefs.sound & SOUND_MENTORHELP)
				X << 'sound/effects/adminhelp.ogg'
			to_chat(X, msg)
	else //Ahelp
		//Open a new adminticket and inform the user.
		SStickets.newTicket(src, prunedmsg, msg)
		for(var/client/X in modholders + adminholders)
			if(X.prefs.sound & SOUND_ADMINHELP)
				X << 'sound/effects/adminhelp.ogg'
			window_flash(X)
			to_chat(X, msg)



	//show it to the person adminhelping too
	to_chat(src, "<span class='boldnotice'>[selected_type]</b>: [original_msg]</span>")

	var/admin_number_present = adminholders.len - admin_number_afk
	log_admin("[selected_type]: [key_name(src)]: [original_msg] - heard by [admin_number_present] non-AFK admins.")
	if(admin_number_present <= 0)
		if(!admin_number_afk)
			send2adminirc("[selected_type] from [key_name(src)]: [original_msg] - !!No admins online!!")
		else
			send2adminirc("[selected_type] from [key_name(src)]: [original_msg] - !!All admins AFK ([admin_number_afk])!!")
	else
		send2adminirc("[selected_type] from [key_name(src)]: [original_msg]")
	feedback_add_details("admin_verb","AH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/proc/send2irc_adminless_only(source, msg, requiredflags = R_BAN)
	var/admin_number_total = 0		//Total number of admins
	var/admin_number_afk = 0		//Holds the number of admins who are afk
	var/admin_number_ignored = 0	//Holds the number of admins without +BAN (so admins who are not really admins)
	var/admin_number_decrease = 0	//Holds the number of admins with are afk, ignored or both
	for(var/client/X in GLOB.admins)
		admin_number_total++;
		var/invalid = 0
		if(requiredflags != 0 && !check_rights_for(X, requiredflags))
			admin_number_ignored++
			invalid = 1
		if(X.is_afk())
			admin_number_afk++
			invalid = 1
		if(X.holder.fakekey)
			admin_number_ignored++
			invalid = 1
		if(invalid)
			admin_number_decrease++
	var/admin_number_present = admin_number_total - admin_number_decrease	//Number of admins who are neither afk nor invalid
	if(admin_number_present <= 0)
		if(!admin_number_afk && !admin_number_ignored)
			send2irc(source, "[msg] - No admins online")
		else
			send2irc(source, "[msg] - All admins AFK ([admin_number_afk]/[admin_number_total]) or skipped ([admin_number_ignored]/[admin_number_total])")
	return admin_number_present
