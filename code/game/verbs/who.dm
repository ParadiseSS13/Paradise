/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/list/lines = list()
	var/list/ckeys = list()

	for(var/client/C in GLOB.clients)
		if(C.holder && C.holder.big_brother) // BB doesn't show up at all
			continue

		if(C.holder && C.holder.fakekey)
			ckeys += C.holder.fakekey
		else
			ckeys += C.key

	ckeys = sortList(ckeys) // Sort it. We dont do this above because fake keys would be out of order, which would be a giveaway

	var/list/output_players = list()

	// Now go over it again to apply colours.
	for(var/player in ckeys)
		var/client/C = GLOB.directory[ckey(player)]
		if(!C)
			// This should NEVER happen, but better to be safe
			continue
		// Get the colour
		var/colour = client2rankcolour(C)
		var/output = "[player]"
		if(C.holder)
			output = "<b>[output]</b>"
		if(colour)
			output = "<font color='[colour]'>[output]</font>"

		output_players += output

	lines += "<b>Current Players ([length(output_players)]): </b>"
	lines += output_players.Join(", ") // Turn players into a comma separated list

	if(check_rights(R_ADMIN, FALSE))
		lines += "Click <a href='byond://?_src_=holder;who_advanced=1'>here</a> for detailed (old) who."

	to_chat(src, lines.Join("<br>"))

// Advanced version of `who` to show player age, antag status and more. Lags the chat when loading, so its in its own proc
/client/proc/who_advanced()
	if(!check_rights(R_ADMIN))
		return

	var/list/Lines = list()

	for(var/client/C in GLOB.clients)
		if(C.holder && C.holder.big_brother && !check_rights(R_PERMISSIONS, FALSE)) // need PERMISSIONS to see BB
			continue

		var/list/entry = list()
		entry += "\t[C.key]"
		if(C.holder && C.holder.fakekey)
			entry += " <i>(as [C.holder.fakekey])</i>"
		entry += " - Playing as [C.mob.real_name]"
		switch(C.mob.stat)
			if(UNCONSCIOUS)
				entry += " - <font color='darkgray'><b>Unconscious</b></font>"
			if(DEAD)
				if(isobserver(C.mob))
					var/mob/dead/observer/observer = C.mob
					if(observer.ghost_flags & GHOST_START_AS_OBSERVER)
						entry += " - <font color='gray'>Observing</font>"
					else
						entry += " - <font color='black'><b>DEAD</b></font>"
				else if(isnewplayer(C.mob))
					entry += " - <font color='green'>New Player</font>"
				else
					entry += " - <font color='black'><b>DEAD</b></font>"

		var/account_age
		if(isnum(C.player_age))
			account_age = C.player_age
		else
			account_age = 0

		if(account_age <= 1)
			account_age = "<font color='#ff0000'><b>[account_age]</b></font>"
		else if(account_age < 10)
			account_age = "<font color='#ff8c00'><b>[account_age]</b></font>"

		entry += " - [account_age]"

		if(is_special_character(C.mob))
			entry += " - <b><font color='red'>Antagonist</font></b>"
		entry += " ([ADMIN_QUE(C.mob, "?")])"

		Lines += entry.Join("")

	var/list/msg = list()

	for(var/line in sortList(Lines))
		msg += "[line]"

	msg += "<b>Total Players: [length(Lines)]</b>"
	to_chat(src, msg.Join("<br>"))

/client/verb/adminwho()
	set category = "Admin"
	set name = "Adminwho"

	var/list/adminmsg = list()
	var/list/mentormsg = list()
	var/list/devmsg = list()
	var/num_mentors_online = 0
	var/num_admins_online = 0
	var/num_devs_online = 0

	for(var/client/C in GLOB.admins)
		var/list/line = list()
		var/rank_colour = client2rankcolour(C)
		if(rank_colour)
			line += "<font color='[rank_colour]'><b>[C]</b></font> is a [C.holder.rank]"
		else
			line += "<b>[C]</b> is a [C.holder.rank]"

		if(holder) // Only for those with perms see the extra bit
			if(C.holder.fakekey && check_rights(R_ADMIN, FALSE))
				line += " <i>(as [C.holder.fakekey])</i>"

			if(isobserver(C.mob))
				line += " - Observing"
			else if(isnewplayer(C.mob))
				line += " - Lobby"
			else
				line += " - Playing"

			if(C.is_afk())
				line += " (AFK)"

		line += "<br>"
		if(check_rights(R_ADMIN, FALSE, C.mob)) // Is this client an admin?
			if(C?.holder?.fakekey && !check_rights(R_ADMIN, FALSE)) // Only admins can see stealthmins
				continue

			if(C?.holder?.big_brother && !check_rights(R_PERMISSIONS, FALSE)) // Normal admins can't see Big Brother
				continue
			num_admins_online++
			adminmsg += line.Join("")

		else if(check_rights(R_DEV_TEAM, FALSE, C.mob)) // Is this client a developer?
			num_devs_online++
			devmsg += line.Join("")

		else if(check_rights(R_MENTOR, FALSE, C.mob)) // Is this client a mentor?
			num_mentors_online++
			mentormsg += line.Join("")

	var/list/final_message = list()
	if(num_admins_online)
		final_message += "<b>Current Admins ([num_admins_online]):</b><br>"
		final_message += adminmsg
		final_message += "<br>"
	if(num_devs_online)
		final_message += "<b>Current Developers ([num_devs_online]):</b><br>"
		final_message += devmsg
		final_message += "<br>"
	if(num_mentors_online)
		final_message += "<b>Current Mentors ([num_mentors_online]):</b><br>"
		final_message += mentormsg
		final_message += "<br>"
	if(!num_admins_online || !num_mentors_online)
		final_message += "<span class='notice'>Even with no [!num_admins_online ? "admins" : ""][!num_admins_online && !num_mentors_online ? " or " : ""][!num_mentors_online ? "mentors" : ""] are online, make a ticket anyways. [!num_admins_online ? "Adminhelps" : ""][!num_admins_online && !num_mentors_online ? " and " : ""][!num_mentors_online ? "Mentorhelps" : ""] will be relayed to discord, and staff will still be informed.</span>"
	to_chat(src, final_message.Join(""))
