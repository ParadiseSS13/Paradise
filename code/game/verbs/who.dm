
/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = "<b>Онлайн Игроков:</b>\n"


	var/list/Lines = list()

	if(check_rights(R_ADMIN,0))
		for(var/client/C in GLOB.clients)
			if(C.holder && C.holder.big_brother && !check_rights(R_PERMISSIONS, 0)) // need PERMISSIONS to see BB
				continue

			var/entry = "\t[C.key]"
			if(C.holder && C.holder.fakekey)
				entry += " <i>(как [C.holder.fakekey])</i>"
			entry += " - Играет за [C.mob.real_name]"
			switch(C.mob.stat)
				if(UNCONSCIOUS)
					entry += " - <font color='darkgray'><b>Без сознания</b></font>"
				if(DEAD)
					if(isobserver(C.mob))
						var/mob/dead/observer/O = C.mob
						if(O.started_as_observer)
							entry += " - <font color='gray'>Наблюдает</font>"
						else
							entry += " - <font color='black'><b>МЕРТВ</b></font>"
					else if(isnewplayer(C.mob))
						entry += " - <font color='green'>Новый Игрок</font>"
					else
						entry += " - <font color='black'><b>МЕРТВ</b></font>"

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
				entry += " - <b><font color='red'>Антагонист</font></b>"
			entry += " ([ADMIN_QUE(C.mob,"?")])"
			entry += " ([round(C.avgping, 1)]ms)"
			Lines += entry
	else
		for(var/client/C in GLOB.clients)
			if(C.holder && C.holder.big_brother) // BB doesn't show up at all
				continue

			if(C.holder && C.holder.fakekey)
				Lines += C.holder.fakekey
			else
				Lines += "[C.key] ([round(C.avgping, 1)]ms)"

	for(var/line in sortList(Lines))
		msg += "[line]\n"

	msg += "<b>Всего Игроков: [length(Lines)]</b>"
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

				msg += "\[[C.holder.rank]\]  \t[C]"

				if(C.holder.fakekey)
					msg += " <i>(как [C.holder.fakekey])</i>"

				if(isobserver(C.mob))
					msg += " - Наблюдает"
				else if(isnewplayer(C.mob))
					msg += " - В Лобби"
				else
					msg += " - Играет"

				if(C.is_afk())
					msg += " (АФК)"
				msg += "\n"

				num_admins_online++

			else if(check_rights(R_MENTOR|R_MOD, 0, C.mob))
				modmsg += "\[[C.holder.rank]\]  \t[C]"

				if(isobserver(C.mob))
					modmsg += " - Наблюдает"
				else if(isnewplayer(C.mob))
					modmsg += " - В Лобби"
				else
					modmsg += " - Играет"

				if(C.is_afk())
					modmsg += " (АФК)"
				modmsg += "\n"
				num_mods_online++
	else
		for(var/client/C in GLOB.admins)

			if(check_rights(R_ADMIN, 0, C.mob))
				if(!C.holder.fakekey)
					msg += "\[[C.holder.rank]\]  \t[C]\n"
					num_admins_online++
			else if(check_rights(R_MOD|R_MENTOR, 0, C.mob) && !check_rights(R_ADMIN, 0, C.mob))
				modmsg += "\[[C.holder.rank]\]  \t[C]\n"
				num_mods_online++

	var/noadmins_info = "\n<span class='notice'><small>Если никого из админсостава нет онлайн, все равно создавайте тикеты. Админхэлпы и менторхэлпы будут перенаправлены в дискорд!<small></span>"
	msg = "<b>Онлайн Админов ([num_admins_online]):</b>\n" + msg + "\n<b>Онлайн Менторов/Модераторов ([num_mods_online]):</b>\n" + modmsg + noadmins_info
	msg = replacetext(msg, "\[Хост\]",	"\[<font color='#1ABC9C'>Хост</font>\]")
	msg = replacetext(msg, "\[Старший Админ\]",	"\[<font color='#f02f2f'>Старший Админ</font>\]")
	msg = replacetext(msg, "\[Админ\]",	"\[<font color='#ee8f29'>Админ</font>\]")
	msg = replacetext(msg, "\[Триал Админ\]",	"\[<font color='#cfc000'>Триал Админ</font>\]")
	msg = replacetext(msg, "\[Модератор\]",	"\[<font color='#9db430'>Модератор</font>\]")
	msg = replacetext(msg, "\[Ментор\]",	"\[<font color='#67761e'>Ментор</font>\]")
	to_chat(src, msg)
