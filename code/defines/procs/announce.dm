GLOBAL_DATUM_INIT(minor_announcement, /datum/announcement/minor, new())
GLOBAL_DATUM_INIT(priority_announcement, /datum/announcement/priority, new(do_log = 0))
GLOBAL_DATUM_INIT(command_announcement, /datum/announcement/priority/command, new(do_log = 0, do_newscast = 0))
GLOBAL_DATUM_INIT(event_announcement, /datum/announcement/priority/command/event, new(do_log = 0, do_newscast = 0))

/datum/announcement
	var/title = "Внимание"
	var/announcer = ""
	var/log = 0
	var/sound
	var/newscast = 0
	var/channel_name = "Station Announcements"
	var/announcement_type = "Оповещение"
	var/admin_announcement = 0 // Admin announcements are received regardless of being in range of a radio, unless you're in the lobby to prevent metagaming
	var/language = "Galactic Common"

/datum/announcement/New(var/do_log = 0, var/new_sound = null, var/do_newscast = 0)
	sound = new_sound
	log = do_log
	newscast = do_newscast

/datum/announcement/minor/New(var/do_log = 0, var/new_sound = sound('sound/misc/announce_dig.ogg'), var/do_newscast = 0)
	..(do_log, new_sound, do_newscast)
	title = "Внимание"
	announcement_type = "Незначительное оповещение"

/datum/announcement/priority/New(var/do_log = 1, var/new_sound = sound('sound/misc/announce_dig.ogg'), var/do_newscast = 0)
	..(do_log, new_sound, do_newscast)
	title = "Приоритетное оповещение"
	announcement_type = "Приоритетное оповещение"

/datum/announcement/priority/command/New(var/do_log = 1, var/new_sound = sound('sound/misc/announce_dig.ogg'), var/do_newscast = 0)
	..(do_log, new_sound, do_newscast)
	admin_announcement = 1
	title = "[command_name()] обновление"
	announcement_type = "[command_name()] обновление"

/datum/announcement/priority/command/event/New(var/do_log = 1, var/new_sound = sound('sound/misc/announce_dig.ogg'), var/do_newscast = 0)
	..(do_log, new_sound, do_newscast)
	admin_announcement = 0

/datum/announcement/priority/security/New(var/do_log = 1, var/new_sound = sound('sound/misc/announce_dig.ogg'), var/do_newscast = 0)
	..(do_log, new_sound, do_newscast)
	title = "Оповещение о безопасности"
	announcement_type = "Оповещение о безопасности"

/datum/announcement/proc/Announce(var/message as text, var/new_title = "", var/new_sound = null, var/do_newscast = newscast, var/msg_sanitized = 0, var/from, var/msg_language)
	if(!message)
		return

	var/message_title = new_title ? new_title : title
	var/message_sound = new_sound ? sound(new_sound) : sound

	if(!msg_sanitized)
		message = trim_strip_html_properly(message, allow_lines = 1)
	message_title = html_encode(message_title)

	var/message_announcer = null
	if(announcer)
		message_announcer = html_encode(announcer)

	var/datum/language/message_language = GLOB.all_languages[msg_language ? msg_language : language]

	var/list/combined_receivers = Get_Receivers(message_language)
	var/list/receivers = combined_receivers[1]
	var/list/garbled_receivers = combined_receivers[2]

	var/formatted_message = Format_Message(message, message_title, message_announcer, from)
	var/garbled_formatted_message = Format_Message(message_language.scramble(message), message_language.scramble(message_title), message_language.scramble(message_announcer), message_language.scramble(from))

	Message(formatted_message, garbled_formatted_message, receivers, garbled_receivers, message_sound)

	if(do_newscast)
		NewsCast(message, message_title)

	Sound(message_sound, combined_receivers[1] + combined_receivers[2])
	Log(message, message_title)

/datum/announcement/proc/Get_Receivers(var/datum/language/message_language)
	var/list/receivers = list()
	var/list/garbled_receivers = list()

	if(admin_announcement)
		for(var/mob/M in GLOB.player_list)
			if(!isnewplayer(M) && M.client)
				receivers |= M
	else
		for(var/obj/item/radio/R in GLOB.global_radios)
			receivers |= R.send_announcement()
		for(var/mob/M in receivers)
			if(!istype(M) || !M.client || M.stat || !M.can_hear())
				receivers -= M
				continue
			if(!M.say_understands(null, message_language))
				receivers -= M
				garbled_receivers |= M
		for(var/mob/M in GLOB.dead_mob_list)
			if(M.client && M.stat == DEAD && !isnewplayer(M))
				receivers |= M

	return list(receivers, garbled_receivers)

/datum/announcement/proc/Message(message, garbled_message, receivers, garbled_receivers, message_sound)
	var/tts_seed = "Glados"
	if(GLOB.ai_list.len)
		var/mob/living/silicon/ai/AI = pick(GLOB.ai_list)
		tts_seed = AI.tts_seed
	var/message_tts = message
	var/garbled_message_tts = garbled_message
	message = replace_characters(message, list("+"))
	garbled_message = replace_characters(garbled_message, list("+"))
	for(var/mob/M in receivers)
		to_chat(M, message)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, null, M, message_tts, tts_seed, FALSE, SOUND_EFFECT_NONE, TTS_TRAIT_RATE_MEDIUM, message_sound)
		log_debug("announcement.Message: [message]")
	for(var/mob/M in garbled_receivers)
		to_chat(M, garbled_message)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, null, M, garbled_message_tts, tts_seed, FALSE, SOUND_EFFECT_NONE, TTS_TRAIT_RATE_MEDIUM, message_sound)
		log_debug("announcement.Message: [garbled_message]")

/datum/announcement/proc/Format_Message(message, message_title, message_announcer, from)
	var/formatted_message
	formatted_message += "<h2 class='alert'>[message_title].</h2>"
	formatted_message += "<br><span class='alert body'>[message]</span>"
	if(message_announcer)
		formatted_message += "<br><span class='alert'> — [message_announcer]</span>"

	return formatted_message

/datum/announcement/minor/Format_Message(message, message_title, message_announcer, from)
	var/formatted_message
	formatted_message += "<b><font size=3><font color=red>[message_title].</font color></font></b>"
	formatted_message += "<br><b><font size=3>[message]</font size></font></b>"

	return formatted_message

/datum/announcement/priority/Format_Message(message, message_title, message_announcer, from)
	var/formatted_message
	formatted_message += "<h1 class='alert'>[message_title].</h1>"
	formatted_message += "<br><span class='alert body'>[message]</span>"
	if(message_announcer)
		formatted_message += "<br><span class='alert'> — [message_announcer]</span>"
	formatted_message += "<br>"

	return formatted_message

/datum/announcement/priority/command/Format_Message(message, message_title, message_announcer, from)
	var/formatted_message
	formatted_message += "<h1 class='alert'>[from]</h1>"
	if(message_title)
		formatted_message += "<br><h2 class='alert body'>[message_title]</h2>"
	formatted_message += "<br><span class='alert'>[message]</span><br>"
	formatted_message += "<br>"

	return formatted_message

/datum/announcement/priority/security/Format_Message(message, message_title, message_announcer, from)
	var/formatted_message
	formatted_message += "<font size=4 color='red'>[message_title]</font>"
	formatted_message += "<br><font color='red'>[message]</font>"

	return formatted_message

/datum/announcement/proc/NewsCast(message as text, message_title as text)
	if(!newscast)
		return

	var/datum/news_announcement/news = new
	news.channel_name = channel_name
	news.author = announcer
	news.message = replace_characters(message, list("+"))
	news.message_type = announcement_type
	news.can_be_redacted = 0
	announce_newscaster_news(news)

/datum/announcement/proc/Sound(var/message_sound, var/receivers)
	if(!message_sound)
		return
	for(var/mob/M in receivers)
		if(config.tts_enabled)
			var/volume = M.client.prefs.get_channel_volume(CHANNEL_TTS_RADIO)
			if(volume > 0)
				continue
		SEND_SOUND(M, message_sound)

/datum/announcement/proc/Log(message as text, message_title as text)
	if(log)
		add_game_logs("has made \a [announcement_type]: [message_title] - [message] - [announcer]", usr)
		message_admins("[key_name_admin(usr)] has made \a [announcement_type].")

/proc/GetNameAndAssignmentFromId(var/obj/item/card/id/I)
	// Format currently matches that of newscaster feeds: Registered Name (Assigned Rank)
	return I.assignment ? "[I.registered_name] ([I.assignment])" : I.registered_name
