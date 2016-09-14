/proc/key_name(var/whom, var/include_link = null, var/include_name = 1, var/type = null)
	var/mob/M
	var/client/C
	var/key

	if(!whom)	return "*null*"
	if(istype(whom, /client))
		C = whom
		M = C.mob
		key = C.key
	else if(ismob(whom))
		M = whom
		C = M.client
		key = M.key
	else if(istype(whom, /datum))
		var/datum/D = whom
		return "*invalid:[D.type]*"
	else
		return "*invalid*"

	. = ""

	if(key)
		if(C && C.holder && C.holder.fakekey && !include_name)
			if(include_link)
				. += "<a href='?priv_msg=[C.findStealthKey()];type=[type]'>"
			. += "Administrator"
		else
			if(include_link)
				. += "<a href='?priv_msg=\ref[C];type=[type]'>"
			. += key

		if(include_link)
			if(C)	. += "</a>"
			else	. += " (DC)"
	else
		. += "*no key*"

	if(include_name && M)
		if(M.real_name)
			. += "/([M.real_name])"
		else if(M.name)
			. += "/([M.name])"

	return .

/proc/key_name_admin(var/whom, var/include_name = 1)
	var/message = "[key_name(whom, 1, include_name)](<A HREF='?_src_=holder;adminmoreinfo=\ref[whom]'>?</A>)[isAntag(whom) ? "(A)" : ""][isLivingSSD(whom) ? "<span class='danger'>(SSD!)</span>" : ""] ([admin_jump_link(whom)])"
	return message

/proc/log_and_message_admins(var/message as text)
	log_admin("[key_name(usr)] " + message)
	message_admins("[key_name_admin(usr)] " + message)

/proc/admin_log_and_message_admins(var/message as text)
	log_admin("[key_name(usr)] " + message)
	message_admins("[key_name_admin(usr)] " + message, 1)
