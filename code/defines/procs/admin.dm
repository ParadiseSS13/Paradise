// Always return "Something/(Something)", even if it's an error message.
/proc/key_name(whom, include_link = FALSE, type = null)
	return key_name_helper(whom, TRUE, include_link, type)

/proc/key_name_hidden(whom, include_link = FALSE, type = null)
	return key_name_helper(whom, FALSE, include_link, type)

/proc/key_name_helper(whom, include_name, include_link = FALSE, type = null)
	if(include_link != FALSE && include_link != TRUE)
		log_runtime(EXCEPTION("Key_name was called with an incorrect include_link [include_link]"))

	var/mob/M
	var/client/C
	var/key

	if(!whom)
		return "INVALID/(INVALID)"
	if(istype(whom, /client))
		C = whom
		M = C.mob
		key = C.key
	else if(ismob(whom))
		M = whom
		C = M.client
		key = M.key
	else if(istype(whom, /datum/mind))
		var/datum/mind/D = whom
		key = D.key
		M = D.current
		if(D.current)
			C = D.current.client
	else if(istype(whom, /datum))
		var/datum/D = whom
		return "INVALID/([D.type])"
	else if(istext(whom))
		return "AUTOMATED/([whom])"
	else
		return "INVALID/(INVALID)"

	. = ""

	if(key)
		if(C && C.holder && C.holder.fakekey && !include_name)
			if(include_link)
				. += "<a href='?priv_msg=[C.findStealthKey()];type=[type]'>"
			. += "Administrator"
		else
			if(include_link && C)
				. += "<a href='?priv_msg=\ref[C];type=[type]'>"
			. += key

		if(include_link)
			if(C)	. += "</a>"
			else	. += " (DC)"
	else
		. += "INVALID"

	if(include_name)
		var/name = "INVALID"
		if(M)
			if(M.real_name)
				name = M.real_name
			else if(M.name)
				name = M.name

		. += "/([name])"

	return .

/proc/key_name_admin(whom)
	var/message = "[key_name(whom, 1)](<A HREF='?_src_=holder;adminmoreinfo=\ref[whom]'>?</A>)[isAntag(whom) ? "<font color='red'>(A)</font>" : ""][isLivingSSD(whom) ? "<span class='danger'>(SSD!)</span>" : ""] ([admin_jump_link(whom)])"
	return message

/proc/key_name_mentor(whom)
	// Same as key_name_admin, but does not include (?) or (A) for antags.
	var/message = "[key_name(whom, 1)] [isLivingSSD(whom) ? "<span class='danger'>(SSD!)</span>" : ""] ([admin_jump_link(whom)])"
	return message


/proc/log_and_message_admins(var/message as text)
	log_admin("[key_name(usr)] " + message)
	message_admins("[key_name_admin(usr)] " + message)

/proc/admin_log_and_message_admins(var/message as text)
	log_admin("[key_name(usr)] " + message)
	message_admins("[key_name_admin(usr)] " + message, 1)
