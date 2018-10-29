//allows right clicking mobs to send an admin PM to their client, forwards the selected mob's client to cmd_admin_pm
/client/proc/cmd_admin_pm_context(mob/M as mob in GLOB.mob_list)
	set category = null
	set name = "Admin PM Mob"
	if(!holder)
		to_chat(src, "<font color='red'>Error: Admin-PM-Context: Only administrators may use this command.</font>")
		return
	if( !ismob(M) || !M.client )	return
	cmd_admin_pm(M.client,null)
	feedback_add_details("admin_verb","APMM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//shows a list of clients we could send PMs to, then forwards our choice to cmd_admin_pm
/client/proc/cmd_admin_pm_panel()
	set category = "Admin"
	set name = "Admin PM Name"
	if(!holder)
		to_chat(src, "<font color='red'>Error: Admin-PM-Panel: Only administrators may use this command.</font>")
		return
	var/list/client/targets[0]
	for(var/client/T)
		if(T.mob)
			if(istype(T.mob, /mob/new_player))
				targets["(New Player) - [T]"] = T
			else if(istype(T.mob, /mob/dead/observer))
				targets["[T.mob.name](Ghost) - [T]"] = T
			else
				targets["[T.mob.real_name](as [T.mob.name]) - [T]"] = T
		else
			targets["(No Mob) - [T]"] = T
	var/list/sorted = sortList(targets)
	var/target = input(src,"To whom shall we send a message?","Admin PM",null) in sorted|null
	cmd_admin_pm(targets[target],null)
	feedback_add_details("admin_verb","APM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//shows a list of clients we could send PMs to, then forwards our choice to cmd_admin_pm
/client/proc/cmd_admin_pm_by_key_panel()
	set category = "Admin"
	set name = "Admin PM Key"
	if(!holder)
		to_chat(src, "<font color='red'>Error: Admin-PM-Panel: Only administrators may use this command.</font>")
		return
	var/list/client/targets[0]
	for(var/client/T)
		if(T.mob)
			if(istype(T.mob, /mob/new_player))
				targets["[T] - (New Player)"] = T
			else if(istype(T.mob, /mob/dead/observer))
				targets["[T] - [T.mob.name](Ghost)"] = T
			else
				targets["[T] - [T.mob.real_name](as [T.mob.name])"] = T
		else
			targets["(No Mob) - [T]"] = T
	var/list/sorted = sortList(targets)
	var/target = input(src,"To whom shall we send a message?","Admin PM",null) in sorted|null
	cmd_admin_pm(targets[target],null)
	feedback_add_details("admin_verb","APM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


//takes input from cmd_admin_pm_context, cmd_admin_pm_panel or /client/Topic and sends them a PM.
//Fetching a message if needed. src is the sender and C is the target client
/client/proc/cmd_admin_pm(whom, msg, type = "PM")
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<font color='red'>Error: Private-Message: You are unable to use PM-s (muted).</font>")
		return

	var/client/C
	if(istext(whom))
		if(cmptext(copytext(whom,1,2),"@"))
			whom = findStealthKey(whom)
		C = GLOB.directory[whom]
	else if(istype(whom,/client))
		C = whom

	if(!C)
		if(holder)
			to_chat(src, "<span class='danger'>Error: Private-Message: Client not found.</span>")
		else
			adminhelp(msg)	//admin we are replying to left. adminhelp instead
		return

	/*if(C && C.last_pm_recieved + config.simultaneous_pm_warning_timeout > world.time && holder)
		//send a warning to admins, but have a delay popup for mods
		if(holder.rights & R_ADMIN)
			to_chat(src, "<span class='danger'>Simultaneous PMs warning:</span> that player has been PM'd in the last [config.simultaneous_pm_warning_timeout / 10] seconds by: [C.ckey_last_pm]")
		else
			if(alert("That player has been PM'd in the last [config.simultaneous_pm_warning_timeout / 10] seconds by: [C.ckey_last_pm]","Simultaneous PMs warning","Continue","Cancel") == "Cancel")
				return*/

	//get message text, limit it's length.and clean/escape html
	if(!msg)
		msg = input(src,"Message:", "Private message to [holder ? key_name(C, FALSE) : key_name_hidden(C, FALSE)]") as text|null

		if(!msg)
			return
		if(!C)
			if(holder)
				to_chat(src, "<span class='danger'>Error: Admin-PM: Client not found.</span>")
			else
				adminhelp(msg)	//admin we are replying to has vanished, adminhelp instead
			return

	if(handle_spam_prevention(msg, MUTE_ADMINHELP, OOC_COOLDOWN))
		return

	//clean the message if it's not sent by a high-rank admin
	if(!check_rights(R_SERVER|R_DEBUG,0))
		msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
		if(!msg)
			return

	var/recieve_span = "playerreply"
	var/send_pm_type = " "
	var/recieve_pm_type = "Player"


	if(holder)
		//mod PMs are maroon
		//PMs sent from admins and mods display their rank
		if(holder)
			if(check_rights(R_MOD|R_MENTOR,0) && !check_rights(R_ADMIN,0))
				recieve_span = "mentorhelp"
			else
				recieve_span = "adminhelp"
			send_pm_type = holder.rank + " "
			recieve_pm_type = holder.rank

	else if(!C.holder)
		to_chat(src, "<font color='red'>Error: Admin-PM: Non-admin to non-admin PM communication is forbidden.</font>")
		return

	var/recieve_message = ""

	if(holder && !C.holder)
		recieve_message = "<span class='[recieve_span]' size='3'>-- Click the [recieve_pm_type]'s name to reply --</span>\n"
		if(C.adminhelped)
			window_flash(C)
			to_chat(C, recieve_message)
			C.adminhelped = 0

		//AdminPM popup for ApocStation and anybody else who wants to use it. Set it with POPUP_ADMIN_PM in config.txt ~Carn
		if(config.popup_admin_pm)
			spawn(0)	//so we don't hold the caller proc up
				var/sender = src
				var/sendername = key
				var/reply = input(C, msg,"[recieve_pm_type] [type] from-[sendername]", "") as text|null		//show message and await a reply
				if(C && reply)
					if(sender)
						C.cmd_admin_pm(sender,reply)										//sender is still about, let's reply to them
					else
						adminhelp(reply)													//sender has left, adminhelp instead
				return


	var/emoji_msg = "<span class='emoji_enabled'>[msg]</span>"
	recieve_message = "<span class='[recieve_span]'>[type] from-<b>[recieve_pm_type][C.holder ? key_name(src, TRUE, type) : key_name_hidden(src, TRUE, type)]</b>: [emoji_msg]</span>"
	to_chat(C, recieve_message)
	to_chat(src, "<font color='blue'>[send_pm_type][type] to-<b>[holder ? key_name(C, TRUE, type) : key_name_hidden(C, TRUE, type)]</b>: [emoji_msg]</font>")

	/*if(holder && !C.holder)
		C.last_pm_recieved = world.time
		C.ckey_last_pm = ckey*/

	//play the recieving admin the adminhelp sound (if they have them enabled)
	//non-admins always hear the sound, as they cannot toggle it
	if((!C.holder) || (C.prefs.sound & SOUND_ADMINHELP))
		C << 'sound/effects/adminhelp.ogg'

	log_admin("PM: [key_name(src)]->[key_name(C)]: [msg]")
	//we don't use message_admins here because the sender/receiver might get it too
	for(var/client/X in GLOB.admins)
		//check client/X is an admin and isn't the sender or recipient
		if(X == C || X == src)
			continue
		if(X.key != key && X.key != C.key)
			switch(type)
				if("Mentorhelp")
					if(check_rights(R_ADMIN|R_MOD|R_MENTOR, 0, X.mob))
						to_chat(X, "<span class='mentorhelp'>[type]: [key_name(src, TRUE, type)]-&gt;[key_name(C, TRUE, type)]: [emoji_msg]</span>")
				if("Adminhelp")
					if(check_rights(R_ADMIN|R_MOD, 0, X.mob))
						to_chat(X, "<span class='adminhelp'>[type]: [key_name(src, TRUE, type)]-&gt;[key_name(C, TRUE, type)]: [emoji_msg]</span>")
				else
					if(check_rights(R_ADMIN|R_MOD, 0, X.mob))
						to_chat(X, "<span class='boldnotice'>[type]: [key_name(src, TRUE, type)]-&gt;[key_name(C, TRUE, type)]: [emoji_msg]</span>")

	if(type == "Mentorhelp")
		return
	//Check if the mob being PM'd has any open admin tickets.
	var/tickets = list()
	tickets = SStickets.checkForTicket(C)
	if(tickets)
		for(var/datum/admin_ticket/i in tickets)
			i.addResponse(src, msg) // Add this response to their open tickets.
		return

	if(check_rights(R_ADMIN|R_MOD, 0, C.mob)) //Is the person being pm'd an admin? If so we check if the pm'er has open tickets
		tickets = SStickets.checkForTicket(src)
		if(tickets)
			for(var/datum/admin_ticket/i in tickets)
				i.addResponse(src, msg)
			return


/client/proc/cmd_admin_irc_pm()
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<font color='red'>Error: Private-Message: You are unable to use PM-s (muted).</font>")
		return

	var/msg = input(src,"Message:", "Private message to admins on IRC / 400 character limit") as text|null

	if(!msg)
		return

	sanitize(msg)

	if(length(msg) > 400) // TODO: if message length is over 400, divide it up into seperate messages, the message length restriction is based on IRC limitations.  Probably easier to do this on the bots ends.
		to_chat(src, "<span class='warning'>Your message was not sent because it was more then 400 characters find your message below for ease of copy/pasting</span>")
		to_chat(src, "<span class='notice'>[msg]</span>")
		return

	send2adminirc("PlayerPM from [key_name(src)]: [html_decode(msg)]")

	to_chat(src, "<font color='blue'>IRC PM to-<b>IRC-Admins</b>: [msg]</font>")

	log_admin("PM: [key_name(src)]->IRC: [msg]")
	for(var/client/X in GLOB.admins)
		if(X == src)
			continue
		if(check_rights(R_ADMIN|R_MOD|R_MENTOR, 0, X.mob))
			to_chat(X, "<B><font color='blue'>PM: [key_name(src, TRUE, 0)]-&gt;IRC-Admins:</B> <span class='notice'>[msg]</span></font>")
