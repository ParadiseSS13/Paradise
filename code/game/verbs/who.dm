/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/list/lines = list()
	var/list/temp = list()

	for(var/client/C in GLOB.clients)
		if(C.holder && C.holder.big_brother) // BB doesn't show up at all
			continue

		if(C.holder && C.holder.fakekey)
			temp += C.holder.fakekey
		else
			temp += C.key

	temp = sortList(temp) // Sort it. We dont do this above because fake keys would be out of order, which would be a giveaway

	var/list/output_players = list()

	// Now go over it again to apply colours.
	for(var/p in temp)
		var/client/C = GLOB.directory[ckey(p)]
		if(!C)
			// This should NEVER happen, but better to be safe
			continue
		// Get the colour
		var/colour = client2rankcolour(C)
		var/out = "[p]"
		if(C.holder)
			out = "<b>[out]</b>"
		if(colour)
			out = "<font color='[colour]'>[out]</font>"

		output_players += out

	lines += "<b>Current Players ([length(output_players)]): </b>"
	lines += output_players.Join(", ") // Turn players into a comma separated list

	if(check_rights(R_ADMIN, FALSE))
		lines += "Click <a href='?_src_=holder;who_advanced=1'>here</a> for detailed (old) who."

	var/msg = lines.Join("\n")

	to_chat(src, msg)

// Advanced version of `who` to show player age, antag status and more. Lags the chat when loading, so its in its own proc
/client/proc/who_advanced()
	if(!check_rights(R_ADMIN))
		return

	var/list/Lines = list()

	for(var/client/C in GLOB.clients)
		if(C.holder && C.holder.big_brother && !check_rights(R_PERMISSIONS, FALSE)) // need PERMISSIONS to see BB
			continue

		var/entry = "\t[C.key]"
		if(C.holder && C.holder.fakekey)
			entry += " <i>(as [C.holder.fakekey])</i>"
		entry += " - Playing as [C.mob.real_name]"
		switch(C.mob.stat)
			if(UNCONSCIOUS)
				entry += " - <font color='darkgray'><b>Unconscious</b></font>"
			if(DEAD)
				if(isobserver(C.mob))
					var/mob/dead/observer/O = C.mob
					if(O.started_as_observer)
						entry += " - <font color='gray'>Observing</font>"
					else
						entry += " - <font color='black'><b>DEAD</b></font>"
				else if(isnewplayer(C.mob))
					entry += " - <font color='green'>New Player</font>"
				else
					entry += " - <font color='black'><b>DEAD</b></font>"

		var/age
		if(isnum(C.player_age))
			age = C.player_age
		else
			age = 0

		if(age <= 1)
			age = "<font color='#ff0000'><b>[age]</b></font>"
		else if(age < 10)
			age = "<font color='#ff8c00'><b>[age]</b></font>"

		entry += " - [age]"

		if(is_special_character(C.mob))
			entry += " - <b><font color='red'>Antagonist</font></b>"
		entry += " ([ADMIN_QUE(C.mob, "?")])"
		Lines += entry

	var/msg = ""

	for(var/line in sortList(Lines))
		msg += "[line]\n"

	msg += "<b>Total Players: [length(Lines)]</b>"
	to_chat(src, msg)

/client/verb/adminwho()
	set category = "Admin"
	set name = "Adminwho"

	var/msg = ""
	var/modmsg = ""
	var/num_mods_online = 0
	var/num_admins_online = 0
	if(holder)
		for(var/client/C in GLOB.admins)
			if(check_rights(R_ADMIN, 0, C.mob))

				if(C.holder.fakekey && !check_rights(R_ADMIN, 0))		//Mentors can't see stealthmins
					continue

				if(C.holder.big_brother && !check_rights(R_PERMISSIONS, 0))		// normal admins can't see BB
					continue

				// Their rank may not have a defined colour, only set colour if so
				var/rank_colour = client2rankcolour(C)
				if(rank_colour)
					msg += "<font color='[rank_colour]'><b>[C]</b></font> is a [C.holder.rank]"
				else
					msg += "<b>[C]</b> is a [C.holder.rank]"

				if(C.holder.fakekey)
					msg += " <i>(as [C.holder.fakekey])</i>"

				if(isobserver(C.mob))
					msg += " - Observing"
				else if(isnewplayer(C.mob))
					msg += " - Lobby"
				else
					msg += " - Playing"

				if(C.is_afk())
					msg += " (AFK)"
				msg += "\n"

				num_admins_online++

			else if(check_rights(R_MENTOR|R_MOD, 0, C.mob))
				// Their rank may not have a defined colour, only set colour if so
				var/rank_colour = client2rankcolour(C)
				if(rank_colour)
					modmsg += "<font color='[rank_colour]'><b>[C]</b></font> is a [C.holder.rank]"
				else
					modmsg += "<b>[C]</b> is a [C.holder.rank]"

				if(isobserver(C.mob))
					modmsg += " - Observing"
				else if(isnewplayer(C.mob))
					modmsg += " - Lobby"
				else
					modmsg += " - Playing"

				if(C.is_afk())
					modmsg += " (AFK)"
				modmsg += "\n"
				num_mods_online++
	else
		for(var/client/C in GLOB.admins)

			if(check_rights(R_ADMIN, 0, C.mob))
				if(!C.holder.fakekey)
					var/rank_colour = client2rankcolour(C)
					if(rank_colour)
						msg += "<font color='[rank_colour]'><b>[C]</b></font> is a [C.holder.rank]"
					else
						msg += "<b>[C]</b> is a [C.holder.rank]"
					msg += "\n"
					num_admins_online++
			else if(check_rights(R_MOD|R_MENTOR, 0, C.mob) && !check_rights(R_ADMIN, 0, C.mob))
				var/rank_colour = client2rankcolour(C)
				if(rank_colour)
					modmsg += "<font color='[rank_colour]'><b>[C]</b></font> is a [C.holder.rank]"
				else
					modmsg += "<b>[C]</b> is a [C.holder.rank]"
				modmsg += "\n"
				num_mods_online++

	var/noadmins_info = "\n<span class='notice'><small>Si no hay administradores o mentors online, de igual forma haz un ticket. Los adminhelps y mentorhelps seran enviados a discord y el staff sera informado.<small></span>"
	msg = "<b>Current Admins ([num_admins_online]):</b>\n" + msg + "\n<b>Current Mentors ([num_mods_online]):</b>\n" + modmsg + noadmins_info
	to_chat(src, msg)
