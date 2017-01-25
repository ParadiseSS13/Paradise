
/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = "<b>Current Players:</b>\n"


	var/list/Lines = list()

	if(check_rights(R_ADMIN,0))
		for(var/client/C in clients)
			if(C.holder && C.holder.big_brother && !check_rights(R_PERMISSIONS, 0)) // need PERMISSIONS to see BB
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
					else if(istype(C.mob, /mob/new_player))
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
			entry += " (<A HREF='?_src_=holder;adminmoreinfo=\ref[C.mob]'>?</A>)"
			Lines += entry
	else
		for(var/client/C in clients)
			if(C.holder && C.holder.big_brother) // BB doesn't show up at all
				continue

			if(C.holder && C.holder.fakekey)
				Lines += C.holder.fakekey
			else
				Lines += C.key

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
		for(var/client/C in admins)
			if(check_rights(R_ADMIN, 0, C.mob))

				if(C.holder.fakekey && !check_rights(R_ADMIN, 0))		//Mentors/Mods can't see stealthmins
					continue
				
				if(C.holder.big_brother && !check_rights(R_PERMISSIONS, 0))		// normal admins can't see BB
					continue

				msg += "\t[C] is a [C.holder.rank]"

				if(C.holder.fakekey)
					msg += " <i>(as [C.holder.fakekey])</i>"

				if(isobserver(C.mob))
					msg += " - Observing"
				else if(istype(C.mob,/mob/new_player))
					msg += " - Lobby"
				else
					msg += " - Playing"

				if(C.is_afk())
					msg += " (AFK)"
				msg += "\n"

				num_admins_online++

			else if(check_rights(R_MENTOR|R_MOD, 0, C.mob))
				modmsg += "\t[C] is a [C.holder.rank]"

				if(isobserver(C.mob))
					modmsg += " - Observing"
				else if(istype(C.mob,/mob/new_player))
					modmsg += " - Lobby"
				else
					modmsg += " - Playing"

				if(C.is_afk())
					modmsg += " (AFK)"
				modmsg += "\n"
				num_mods_online++
	else
		for(var/client/C in admins)

			if(check_rights(R_ADMIN, 0, C.mob))
				if(!C.holder.fakekey)
					msg += "\t[C] is a [C.holder.rank]\n"
					num_admins_online++
			else if(check_rights(R_MOD|R_MENTOR, 0, C.mob) && !check_rights(R_ADMIN, 0, C.mob))
				modmsg += "\t[C] is a [C.holder.rank]\n"
				num_mods_online++

	msg = "<b>Current Admins ([num_admins_online]):</b>\n" + msg + "\n<b>Current Mods/Mentors ([num_mods_online]):</b>\n" + modmsg
	to_chat(src, msg)
