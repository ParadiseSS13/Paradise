// Always return "Something/(Something)", even if it's an error message.
/proc/key_name(whom, include_link = FALSE, type = null)
	return key_name_helper(whom, TRUE, include_link, type)

/proc/key_name_hidden(whom, include_link = FALSE, type = null)
	return key_name_helper(whom, FALSE, include_link, type)

/proc/key_name_helper(whom, include_name, include_link = FALSE, type = null)
	if(include_link != FALSE && include_link != TRUE)
		log_runtime(EXCEPTION("Key_name was called with an incorrect include_link [include_link]"), src)

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
				. += "<a href='?priv_msg=[C.UID()];type=[type]'>"
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
	if(whom)
		var/datum/whom_datum = whom //As long as it's not null, will be close enough/has the proc UID() that is all that's needed
		var/message = "[key_name(whom, 1)]([ADMIN_QUE(whom_datum,"?")])[isAntag(whom) ? "<font color='red'>(A)</font>" : ""][isLivingSSD(whom) ? "<span class='danger'>(SSD!)</span>" : ""] ([admin_jump_link(whom)])"
		return message

/proc/key_name_mentor(whom)
	// Same as key_name_admin, but does not include (?) or (A) for antags.
	var/message = "[key_name(whom, 1)] [isLivingSSD(whom) ? "<span class='danger'>(SSD!)</span>" : ""] ([admin_jump_link(whom)])"
	return message

/proc/key_name_log(whom)
	// Key_name_admin, but does not include (?) or jump link - For logging purpose to reduce clutter while figuring out who is SSD and/or antag when being attacked. Also remove formatting since it is not displayed
	var/message = "[key_name(whom, 0)][isAntag(whom) ? "(ANTAG)" : ""][isLivingSSD(whom) ? "(SSD!)": ""]"
	return message

/proc/log_and_message_admins(var/message as text)
	log_admin("[key_name(usr)] " + message)
	message_admins("[key_name_admin(usr)] " + message)

/proc/admin_log_and_message_admins(var/message as text)
	log_admin("[key_name(usr)] " + message)
	message_admins("[key_name_admin(usr)] " + message, 1)
