#define SAY_ENABLED TRUE
#define SAY_DISABLED FALSE

GLOBAL_LIST_INIT(say_status, list(
	"msay" = SAY_ENABLED,
))

ADMIN_VERB(admin_say, R_ADMIN, "Asay", "Asay", VERB_CATEGORY_HIDDEN, msg as text)
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

	var/display_color = user.get_staffsay_color()
	for(var/client/C in GLOB.admins)
		var/temp_message = msg
		if(R_ADMIN & C.holder.rights)
			// Lets see if this admin was pinged in the asay message
			if(findtext(temp_message, "@[C.ckey]") || findtext(temp_message, "@[C.key]")) // Check ckey and key, so you can type @AffectedArc07 or @affectedarc07
				SEND_SOUND(C, sound('sound/misc/ping.ogg'))
				temp_message = replacetext(temp_message, "@[C.ckey]", "<font color='red'>@[C.ckey]</font>")
				temp_message = replacetext(temp_message, "@[C.key]", "<font color='red'>@[C.key]</font>") // Same applies here. key and ckey.

			temp_message = "<span class='emoji_enabled'>[temp_message]</span>"
			to_chat(C, "<span class='admin_channel'>ADMIN: <font color='[display_color]'>[key_name(usr, 1)]</font> ([admin_jump_link(user.mob)]): <span class='message'>[temp_message]</span></span>", MESSAGE_TYPE_ADMINCHAT, confidential = TRUE)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Asay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

ADMIN_VERB(dev_say, R_ADMIN|R_DEV_TEAM, "Devsay", "Devsay", VERB_CATEGORY_HIDDEN, msg as text)
	msg = emoji_parse(copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN))

	if(!msg)
		return

	log_devsay(msg, src)
	var/datum/say/devsay = new(usr.ckey, usr.client.holder.rank, msg, world.timeofday)
	GLOB.devsays += devsay
	user.mob.create_log(OOC_LOG, "DEVSAY: [msg]")

	if(SSredis.connected)
		var/list/data = list()
		data["author"] = usr.ckey
		data["source"] = GLOB.configuration.system.instance_id
		data["message"] = html_decode(msg)
		SSredis.publish("byond.devsay", json_encode(data))

	var/display_color = user.get_staffsay_color()
	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN|R_MOD|R_DEV_TEAM, 0, C.mob))
			var/display_name = user.key
			if(user.holder.fakekey)
				if(C.holder && C.holder.rights & R_ADMIN)
					display_name = "[user.holder.fakekey]/([user.key])"
				else
					display_name = user.holder.fakekey
			msg = "<span class='emoji_enabled'>[msg]</span>"
			to_chat(C, "<span class='[check_rights(R_ADMIN, 0) ? "dev_channel_admin" : "dev_channel"]'>DEV: <font color='[display_color]'>[display_name]</font> ([admin_jump_link(user.mob)]): <span class='message'>[msg]</span></span>", MESSAGE_TYPE_DEVCHAT, confidential = TRUE)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Devsay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

ADMIN_VERB(staff_say, R_ADMIN|R_MENTOR|R_DEV_TEAM, "Staffsay", "Staffsay", VERB_CATEGORY_HIDDEN, msg as text)
	if(!check_rights())
		return

	msg = emoji_parse(copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN))

	if(!msg)
		return

	log_staffsay(msg, src)
	var/datum/say/staffsay = new(usr.ckey, usr.client.holder.rank, msg, world.timeofday)
	GLOB.staffsays += staffsay
	user.mob.create_log(OOC_LOG, "STAFFSAY: [msg]")

	if(SSredis.connected)
		var/list/data = list()
		data["author"] = usr.ckey
		data["source"] = GLOB.configuration.system.instance_id
		data["message"] = html_decode(msg)
		SSredis.publish("byond.staffsay", json_encode(data))

	var/display_color = user.get_staffsay_color()
	for(var/client/C in GLOB.admins)
		if(check_rights(0, 0, C.mob))
			var/display_name = user.key
			if(user.holder.fakekey)
				if(C.holder && C.holder.rights & R_ADMIN)
					display_name = "[user.holder.fakekey]/([user.key])"
				else
					display_name = user.holder.fakekey
			msg = "<span class='emoji_enabled'>[msg]</span>"
			to_chat(C, "<span class='[check_rights(R_ADMIN, 0) ? "staff_channel_admin" : "staff_channel"]'>STAFF: <font color='[display_color]'>[display_name]</font> ([admin_jump_link(user.mob)]): <span class='message'>[msg]</span></span>", MESSAGE_TYPE_STAFFCHAT, confidential = TRUE)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Staffsay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

ADMIN_VERB(mentor_say, R_ADMIN|R_MENTOR|R_MOD, "Msay", "Use mentorsay.", VERB_CATEGORY_HIDDEN, msg as text)
	if(GLOB.say_status["msay"] != SAY_ENABLED)
		to_chat(user, "<b>Mentor chat has been disabled.</b>")
		return

	msg = emoji_parse(copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN))
	log_mentorsay(msg, src)
	var/datum/say/msay = new(usr.ckey, usr.client.holder.rank, msg, world.timeofday)
	GLOB.msays += msay
	user.mob.create_log(OOC_LOG, "MSAY: [msg]")

	if(!msg)
		return

	// Do this up here before it gets sent to everyone & emoji'd
	if(SSredis.connected)
		var/list/data = list()
		data["author"] = usr.ckey
		data["source"] = GLOB.configuration.system.instance_id
		data["message"] = html_decode(msg)
		SSredis.publish("byond.msay", json_encode(data))

	var/display_color = user.get_staffsay_color()
	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN|R_MOD|R_MENTOR, 0, C.mob))
			var/display_name = user.key
			if(user.holder.fakekey)
				if(C.holder && C.holder.rights & R_ADMIN)
					display_name = "[user.holder.fakekey]/([user.key])"
				else
					display_name = user.holder.fakekey
			msg = "<span class='emoji_enabled'>[msg]</span>"
			to_chat(C, "<span class='[check_rights(R_ADMIN, 0) ? "mentor_channel_admin" : "mentor_channel"]'>MENTOR: <font color='[display_color]'>[display_name]</font> ([admin_jump_link(user.mob)]): <span class='message'>[msg]</span></span>", MESSAGE_TYPE_MENTORCHAT, confidential = TRUE)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Msay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

ADMIN_VERB(toggle_mentor_chat, R_ADMIN, "Toggle Mentor Chat", "Toggle whether mentors have access to the msay command", VERB_CATEGORY_SERVER)
	var/enabling

	if(GLOB.say_status["msay"] == SAY_ENABLED)
		enabling = FALSE
		GLOB.say_status["msay"] = SAY_DISABLED
	else
		enabling = TRUE
		GLOB.say_status["msay"] = SAY_ENABLED

	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN|R_MOD, 0, C.mob))
			continue
		if(!check_rights(R_MENTOR, 0, C.mob))
			continue
		if(enabling)
			to_chat(C, "<b>Mentor chat has been enabled.</b> Use 'msay' to speak in it.")
		else
			to_chat(C, "<b>Mentor chat has been disabled.</b>")

	log_and_message_admins("toggled mentor chat [enabling ? "on" : "off"].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Msay")

/client/proc/get_staffsay_color()
	if(!GLOB.configuration.admin.allow_admin_ooc_colour || !check_rights(R_ADMIN, FALSE))
		return client2rankcolour(src)
	return prefs.ooccolor

#undef SAY_ENABLED
#undef SAY_DISABLED
