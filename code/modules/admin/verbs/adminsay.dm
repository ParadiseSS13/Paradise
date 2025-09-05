/client/proc/cmd_admin_say(msg as text)
	set name = "Asay" //Gave this shit a shorter name so you only have to time out "asay" rather than "admin say" to use it --NeoFite
	set hidden = 1
	if(!check_rights(R_ADMIN))
		return

	msg = emoji_parse(copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN))
	if(!msg)
		return

	var/datum/say/asay = new(usr.ckey, usr.client.holder.rank, msg, world.timeofday)
	GLOB.asays += asay
	log_adminsay(msg, src)

	// Do this up here before it gets sent to everyone & emoji'd
	if(SSredis.connected)
		var/list/data = list()
		data["author"] = usr.ckey
		data["source"] = GLOB.configuration.system.instance_id
		data["message"] = html_decode(msg)
		SSredis.publish("byond.asay", json_encode(data))

	var/display_color = get_staffsay_color()
	for(var/client/C in GLOB.admins)
		var/temp_message = msg
		if(R_ADMIN & C.holder.rights)
			// Lets see if this admin was pinged in the asay message
			if(findtext(temp_message, "@[C.ckey]") || findtext(temp_message, "@[C.key]")) // Check ckey and key, so you can type @AffectedArc07 or @affectedarc07
				SEND_SOUND(C, sound('sound/misc/ping.ogg'))
				temp_message = replacetext(temp_message, "@[C.ckey]", "<font color='red'>@[C.ckey]</font>")
				temp_message = replacetext(temp_message, "@[C.key]", "<font color='red'>@[C.key]</font>") // Same applies here. key and ckey.

			temp_message = "<span class='emoji_enabled'>[temp_message]</span>"
			to_chat(C, "<span class='admin_channel'>ADMIN: <font color='[display_color]'>[key_name(usr, 1)]</font> ([admin_jump_link(mob)]): <span class='message'>[temp_message]</span></span>", MESSAGE_TYPE_ADMINCHAT, confidential = TRUE)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Asay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_dev_say(msg as text)
	set name = "Devsay"
	set hidden = TRUE

	if(!check_rights(R_ADMIN|R_DEV_TEAM)) // Catch any non-admins trying to use this proc
		return

	msg = emoji_parse(copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN))

	if(!msg)
		return

	log_devsay(msg, src)
	var/datum/say/devsay = new(usr.ckey, usr.client.holder.rank, msg, world.timeofday)
	GLOB.devsays += devsay
	mob.create_log(OOC_LOG, "DEVSAY: [msg]")

	if(SSredis.connected)
		var/list/data = list()
		data["author"] = usr.ckey
		data["source"] = GLOB.configuration.system.instance_id
		data["message"] = html_decode(msg)
		SSredis.publish("byond.devsay", json_encode(data))

	var/display_color = get_staffsay_color()
	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN|R_MOD|R_DEV_TEAM, 0, C.mob))
			var/display_name = key
			if(holder.fakekey)
				if(C.holder && C.holder.rights & R_ADMIN)
					display_name = "[holder.fakekey]/([key])"
				else
					display_name = holder.fakekey
			msg = "<span class='emoji_enabled'>[msg]</span>"
			to_chat(C, "<span class='[check_rights(R_ADMIN, 0) ? "dev_channel_admin" : "dev_channel"]'>DEV: <font color='[display_color]'>[display_name]</font> ([admin_jump_link(mob)]): <span class='message'>[msg]</span></span>", MESSAGE_TYPE_DEVCHAT, confidential = TRUE)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Devsay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_staff_say(msg as text)
	set name = "Staffsay"
	set hidden = TRUE

	if(!check_rights(R_DEV_TEAM|R_ADMIN|R_MENTOR))
		return

	msg = emoji_parse(copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN))

	if(!msg)
		return

	log_staffsay(msg, src)
	var/datum/say/staffsay = new(usr.ckey, usr.client.holder.rank, msg, world.timeofday)
	GLOB.staffsays += staffsay
	mob.create_log(OOC_LOG, "STAFFSAY: [msg]")

	if(SSredis.connected)
		var/list/data = list()
		data["author"] = usr.ckey
		data["source"] = GLOB.configuration.system.instance_id
		data["message"] = html_decode(msg)
		SSredis.publish("byond.staffsay", json_encode(data))

	var/display_color = get_staffsay_color()
	for(var/client/C in GLOB.admins)
		if(check_rights(0, 0, C.mob))
			var/display_name = key
			if(holder.fakekey)
				if(C.holder && C.holder.rights & R_ADMIN)
					display_name = "[holder.fakekey]/([key])"
				else
					display_name = holder.fakekey
			msg = "<span class='emoji_enabled'>[msg]</span>"
			to_chat(C, "<span class='[check_rights(R_ADMIN, 0) ? "staff_channel_admin" : "staff_channel"]'>STAFF: <font color='[display_color]'>[display_name]</font> ([admin_jump_link(mob)]): <span class='message'>[msg]</span></span>", MESSAGE_TYPE_STAFFCHAT, confidential = TRUE)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Staffsay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_mentor_say(msg as text)
	set name = "Msay"
	set hidden = 1

	if(check_rights(R_MENTOR, FALSE)) // Mentor detected, check if the verb has been disabled for mentors
		var/msay_found = FALSE
		for(var/procs as anything in GLOB.admin_verbs_mentor)
			if(procs == /client/proc/cmd_mentor_say)
				msay_found = TRUE
				break
		if(!msay_found)
			to_chat(src, "<b>Mentor chat has been disabled.</b>")
			return

	else if(!check_rights(R_ADMIN|R_MOD)) // Catch any other non-admins trying to use this proc
		return

	msg = emoji_parse(copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN))
	log_mentorsay(msg, src)
	var/datum/say/msay = new(usr.ckey, usr.client.holder.rank, msg, world.timeofday)
	GLOB.msays += msay
	mob.create_log(OOC_LOG, "MSAY: [msg]")

	if(!msg)
		return

	// Do this up here before it gets sent to everyone & emoji'd
	if(SSredis.connected)
		var/list/data = list()
		data["author"] = usr.ckey
		data["source"] = GLOB.configuration.system.instance_id
		data["message"] = html_decode(msg)
		SSredis.publish("byond.msay", json_encode(data))

	var/display_color = get_staffsay_color()
	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN|R_MOD|R_MENTOR, 0, C.mob))
			var/display_name = key
			if(holder.fakekey)
				if(C.holder && C.holder.rights & R_ADMIN)
					display_name = "[holder.fakekey]/([key])"
				else
					display_name = holder.fakekey
			msg = "<span class='emoji_enabled'>[msg]</span>"
			to_chat(C, "<span class='[check_rights(R_ADMIN, 0) ? "mentor_channel_admin" : "mentor_channel"]'>MENTOR: <font color='[display_color]'>[display_name]</font> ([admin_jump_link(mob)]): <span class='message'>[msg]</span></span>", MESSAGE_TYPE_MENTORCHAT, confidential = TRUE)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Msay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_mentor_chat()
	set category = "Server"
	set name = "Toggle Mentor Chat"
	set desc = "Toggle whether mentors have access to the msay command"

	if(!check_rights(R_ADMIN))
		return

	var/enabling
	var/msay = /client/proc/cmd_mentor_say

	if(msay in GLOB.admin_verbs_mentor)
		enabling = FALSE
		GLOB.admin_verbs_mentor -= msay
	else
		enabling = TRUE
		GLOB.admin_verbs_mentor += msay

	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN|R_MOD, 0, C.mob))
			continue
		if(!check_rights(R_MENTOR, 0, C.mob))
			continue
		if(enabling)
			add_verb(C, msay)
			to_chat(C, "<b>Mentor chat has been enabled.</b> Use 'msay' to speak in it.")
		else
			remove_verb(C, msay)
			to_chat(C, "<b>Mentor chat has been disabled.</b>")

	log_and_message_admins("toggled mentor chat [enabling ? "on" : "off"].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Msay")

/client/proc/get_staffsay_color()
	if(!GLOB.configuration.admin.allow_admin_ooc_colour || !check_rights(R_ADMIN, FALSE))
		return client2rankcolour(src)
	return prefs.ooccolor
