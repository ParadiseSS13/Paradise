//allows right clicking mobs to send an admin PM to their client, forwards the selected mob's client to cmd_admin_pm
/client/proc/cmd_admin_pm_context(mob/M as mob in mob_list)
	set category = null
	set name = "Admin PM Mob"
	if(!holder)
		src << "<font color='red'>Error: Admin-PM-Context: Only administrators may use this command.</font>"
		return
	if( !ismob(M) || !M.client )	return
	cmd_admin_pm(M.client,null)
	feedback_add_details("admin_verb","APMM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//shows a list of clients we could send PMs to, then forwards our choice to cmd_admin_pm
/client/proc/cmd_admin_pm_panel()
	set category = "Admin"
	set name = "Admin PM Name"
	if(!holder)
		src << "<font color='red'>Error: Admin-PM-Panel: Only administrators may use this command.</font>"
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
		src << "<font color='red'>Error: Admin-PM-Panel: Only administrators may use this command.</font>"
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
/client/proc/cmd_admin_pm(var/client/C, var/msg, var/type="PM")
	if(prefs.muted & MUTE_ADMINHELP)
		src << "<font color='red'>Error: Private-Message: You are unable to use PM-s (muted).</font>"
		return

	if(!istype(C,/client))
		if(holder)	src << "<font color='red'>Error: Private-Message: Client not found.</font>"
		else		adminhelp(msg)	//admin we are replying to left. adminhelp instead
		return

	/*if(C && C.last_pm_recieved + config.simultaneous_pm_warning_timeout > world.time && holder)
		//send a warning to admins, but have a delay popup for mods
		if(holder.rights & R_ADMIN)
			src << "\red <b>Simultaneous PMs warning:</b> that player has been PM'd in the last [config.simultaneous_pm_warning_timeout / 10] seconds by: [C.ckey_last_pm]"
		else
			if(alert("That player has been PM'd in the last [config.simultaneous_pm_warning_timeout / 10] seconds by: [C.ckey_last_pm]","Simultaneous PMs warning","Continue","Cancel") == "Cancel")
				return*/

	//get message text, limit it's length.and clean/escape html
	if(!msg)
		msg = input(src,"Message:", "Private message to [C.key]") as text|null

		if(!msg)	return
		if(!C)
			if(holder)	src << "<font color='red'>Error: Admin-PM: Client not found.</font>"
			else		adminhelp(msg)	//admin we are replying to has vanished, adminhelp instead
			return

	if (src.handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	//clean the message if it's not sent by a high-rank admin
	if(!check_rights(R_SERVER|R_DEBUG,0))
		msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
		if(!msg)	return

	var/recieve_color = "purple"
	var/send_pm_type = " "
	var/recieve_pm_type = "Player"


	if(holder)
		//mod PMs are maroon
		//PMs sent from admins and mods display their rank
		if(holder)
			if( holder.rights & R_MOD && !holder.rights & R_ADMIN )
				recieve_color = "maroon"
			else
				recieve_color = "red"
			send_pm_type = holder.rank + " "
			recieve_pm_type = holder.rank

	else if(!C.holder)
		src << "<font color='red'>Error: Admin-PM: Non-admin to non-admin PM communication is forbidden.</font>"
		return

	var/recieve_message = ""

	if(holder && !C.holder)
		recieve_message = "<font color='[recieve_color]' size='3'><b>-- Click the [recieve_pm_type]'s name to reply --</b></font>\n"
		if(C.adminhelped)
			C << recieve_message
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

	recieve_message = "<font color='[recieve_color]'>[type] from-<b>[recieve_pm_type][key_name(src, C, C.holder ? 1 : 0, type)]</b>: [msg]</font>"
	C << recieve_message
	src << "<font color='blue'>[send_pm_type][type] to-<b>[key_name(C, src, holder ? 1 : 0, type)]</b>: [msg]</font>"

	/*if(holder && !C.holder)
		C.last_pm_recieved = world.time
		C.ckey_last_pm = ckey*/

	//play the recieving admin the adminhelp sound (if they have them enabled)
	//non-admins shouldn't be able to disable this
	if(C.prefs.sound & SOUND_ADMINHELP)
		C << 'sound/effects/adminhelp.ogg'

	/*
	if(C.holder)
		if(holder)	//both are admins
			if(holder.rank == "Moderator") //If moderator
				C << "<font color='maroon'>Mod PM from-<b>[key_name(src, C, 1)]</b>: [msg]</font>"
				src << "<font color='blue'>Mod PM to-<b>[key_name(C, src, 1)]</b>: [msg]</font>"
			else
				C << "<font color='red'>Admin PM from-<b>[key_name(src, C, 1)]</b>: [msg]</font>"
				src << "<font color='blue'>Admin PM to-<b>[key_name(C, src, 1)]</b>: [msg]</font>"

		else		//recipient is an admin but sender is not
			C << "<font color='red'>Reply PM from-<b>[key_name(src, C, 1)]</b>: [msg]</font>"
			src << "<font color='blue'>PM to-<b>Admins</b>: [msg]</font>"

		//play the recieving admin the adminhelp sound (if they have them enabled)
		if(C.prefs.toggles & SOUND_ADMINHELP)
			C << 'sound/effects/adminhelp.ogg'

	else
		if(holder)	//sender is an admin but recipient is not. Do BIG RED TEXT
			if(holder.rank == "Moderator")
				C << "<font color='maroon'>Mod PM from-<b>[key_name(src, C, 0)]</b>: [msg]</font>"
				C << "<font color='maroon'><i>Click on the moderators's name to reply.</i></font>"
				src << "<font color='blue'>Mod PM to-<b>[key_name(C, src, 1)]</b>: [msg]</font>"
			else
				C << "<font color='red' size='4'><b>-- Administrator private message --</b></font>"
				C << "<font color='red'>Admin PM from-<b>[key_name(src, C, 0)]</b>: [msg]</font>"
				C << "<font color='red'><i>Click on the administrator's name to reply.</i></font>"
				src << "<font color='blue'>Admin PM to-<b>[key_name(C, src, 1)]</b>: [msg]</font>"

			//always play non-admin recipients the adminhelp sound
			C << 'sound/effects/adminhelp.ogg'

			//AdminPM popup for ApocStation and anybody else who wants to use it. Set it with POPUP_ADMIN_PM in config.txt ~Carn
			if(config.popup_admin_pm)
				spawn()	//so we don't hold the caller proc up
					var/sender = src
					var/sendername = key
					var/reply = input(C, msg,"Admin PM from-[sendername]", "") as text|null		//show message and await a reply
					if(C && reply)
						if(sender)
							C.cmd_admin_pm(sender,reply)										//sender is still about, let's reply to them
						else
							adminhelp(reply)													//sender has left, adminhelp instead
					return

		else		//neither are admins
			src << "<font color='red'>Error: Admin-PM: Non-admin to non-admin PM communication is forbidden.</font>"
			return
	*/

	log_admin("PM: [key_name(src)]->[key_name(C)]: [msg]")


	var/list/modholders = list()
	var/list/banholders = list()
	var/list/debugholders = list()
	var/list/adminholders = list()
	var/list/eventholders = list()
	for(var/client/X in admins)
		if(R_MOD & X.holder.rights)
			modholders += X
		if(R_ADMIN & X.holder.rights)
			adminholders += X
		if(R_DEBUG & X.holder.rights)
			debugholders += X
		if(R_BAN & X.holder.rights)
			banholders += X
		if(R_EVENT & X.holder.rights)
			eventholders += X

	//we don't use message_admins here because the sender/receiver might get it too
	for(var/client/X in admins)
		//check client/X is an admin and isn't the sender or recipient
		if(X == C || X == src)
			continue
		if(X.key!=key && X.key!=C.key)
			switch(type)
				if("Question")
					if(X.holder.rights & R_MOD)
						X << "<B><font color='blue'>[type]: [key_name(src, X, 0, type)]-&gt;[key_name(C, X, 0, type)]:</B> \blue [msg]</font>" //inform X
					else if(!modholders.len && X.holder.rights & R_ADMIN)
						X << "<B><font color='blue'>[type]: [key_name(src, X, 0, type)]-&gt;[key_name(C, X, 0, type)]:</B> \blue [msg]</font>" //Any admins in backup of mod question
				if("Bug Report")
					if(X.holder.rights & R_DEBUG)
						X << "<B><font color='blue'>[type]: [key_name(src, X, 0, type)]-&gt;[key_name(C, X, 0, type)]:</B> \blue [msg]</font>" //inform X
					else if(!debugholders.len && X.holder.rights & R_ADMIN)
						X << "<B><font color='blue'>[type]: [key_name(src, X, 0, type)]-&gt;[key_name(C, X, 0, type)]:</B> \blue [msg]</font>" //Any admins in backup of bug reports
				if("Event")
					if(X.holder.rights & R_EVENT)
						X << "<B><font color='blue'>[type]: [key_name(src, X, 0, type)]-&gt;[key_name(C, X, 0, type)]:</B> \blue [msg]</font>" //inform X
					else if(!eventholders.len && X.holder.rights & R_BAN)
						X << "<B><font color='blue'>[type]: [key_name(src, X, 0, type)]-&gt;[key_name(C, X, 0, type)]:</B> \blue [msg]</font>" //Quality in backup of Event
				if("Player Complaint")
					if(X.holder.rights & R_BAN)
						X << "<B><font color='blue'>[type]: [key_name(src, X, 0, type)]-&gt;[key_name(C, X, 0, type)]:</B> \blue [msg]</font>" //There should always be at least 1 person with +BAN on
				else
					if((X.holder.rights & R_ADMIN) || (X.holder.rights & R_MOD) )
						X << "<B><font color='blue'>[type]: [key_name(src, X, 0, type)]-&gt;[key_name(C, X, 0, type)]:</B> \blue [msg]</font>" //If there's no type, send to all admins.

/client/proc/cmd_admin_irc_pm()
	if(prefs.muted & MUTE_ADMINHELP)
		src << "<font color='red'>Error: Private-Message: You are unable to use PM-s (muted).</font>"
		return

	var/msg = input(src,"Message:", "Private message to admins on IRC / 400 character limit") as text|null

	if(!msg)
		return

	sanitize(msg)

	if(length(msg) > 400) // TODO: if message length is over 400, divide it up into seperate messages, the message length restriction is based on IRC limitations.  Probably easier to do this on the bots ends.
		src << "\red Your message was not sent because it was more then 400 characters find your message below for ease of copy/pasting"
		src << "\blue [msg]"
		return

	send2adminirc("PlayerPM from [key_name(src)]: [html_decode(msg)]")

	src << "<font color='blue'>IRC PM to-<b>IRC-Admins</b>: [msg]</font>"

	log_admin("PM: [key_name(src)]->IRC: [msg]")
	for(var/client/X in admins)
		if(X == src)
			continue
		if((X.holder.rights & R_ADMIN) || (X.holder.rights & R_MOD))
			X << "<B><font color='blue'>PM: [key_name(src, X, 0)]-&gt;IRC-Admins:</B> \blue [msg]</font>"

