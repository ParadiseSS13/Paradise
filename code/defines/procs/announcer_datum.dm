GLOBAL_DATUM_INIT(minor_announcement, /datum/announcer, new(config_type = /datum/announcement_configuration/minor))
GLOBAL_DATUM_INIT(major_announcement, /datum/announcer, new(config_type = /datum/announcement_configuration/major))

/datum/announcement_configuration
	var/default_title = "Attention"
	/// The name used when describing the announcement type in logs.
	var/log_name = ANNOUNCE_KIND_DEFAULT
	/// Whether or not to log the announcement when made.
	var/add_log = FALSE
	/// Global announcements are received regardless of being in range of a
	/// radio, unless you're in the lobby, to prevent metagaming.
	var/global_announcement = FALSE
	/// What sound to play when the announcement is made.
	var/sound/sound
	/// A CSS class name.
	var/style

/datum/announcer
	// The default configuration for new announcements.
	var/datum/announcement_configuration/config
	/// The name used to sign off on announcements.
	var/author
	var/language = "Galactic Common"

/datum/announcer/New(config_type = null)
	config = config_type ? new config_type : new

// TODO: Make new_sound+new_sound2 a list to clean things up more
/datum/announcer/proc/Announce(
		message,
		new_title = null,
		new_sound = null,
		msg_sanitized = FALSE,
		msg_language,
		new_sound2 = null,
		new_subtitle = null
	)

	if(!message)
		return

	var/title = html_encode(new_title || config.default_title)
	var/subtitle = new_subtitle ? html_encode(new_subtitle) : null
	var/message_sound = new_sound ? sound(new_sound) : config.sound
	var/message_sound2 = new_sound2 ? sound(new_sound2) : null

	if(!msg_sanitized)
		message = html_encode(message)

	var/datum/language/message_language = GLOB.all_languages[msg_language ? msg_language : language]

	var/list/combined_receivers = Get_Receivers(message_language)
	var/list/receivers = combined_receivers[1]
	var/list/garbled_receivers = combined_receivers[2]

	var/formatted_message = Format(message, title, subtitle)
	var/garbled_formatted_message = Format(
		message_language.scramble(message),
		message_language.scramble(title),
		message_language.scramble(subtitle)
	)

	Message(formatted_message, garbled_formatted_message, receivers, garbled_receivers)

	var/datum/feed_message/FM = new
	FM.author = author ? author : "Automated Announcement System"
	FM.title = subtitle ? "[title]: [subtitle]" : "[title]"
	FM.body = message
	GLOB.news_network.get_channel_by_name("Station Announcements Log")?.add_message(FM)

	Sound(message_sound, combined_receivers[1] + combined_receivers[2])
	if(message_sound2)
		Sound(message_sound2, combined_receivers[1] + combined_receivers[2])

	if(config.add_log)
		Log(message, title)

/datum/announcer/proc/Get_Receivers(datum/language/message_language)
	var/list/receivers = list()
	var/list/garbled_receivers = list()

	if(config.global_announcement)
		for(var/mob/M in GLOB.player_list)
			if(!isnewplayer(M) && M.client)
				receivers |= M
			if(!M.say_understands(null, message_language))
				receivers -= M
				garbled_receivers |= M
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

/datum/announcer/proc/Message(message, garbled_message, receivers, garbled_receivers)
	for(var/mob/M in receivers)
		to_chat(M, message, MESSAGE_TYPE_WARNING)
	for(var/mob/M in garbled_receivers)
		to_chat(M, garbled_message, MESSAGE_TYPE_WARNING)

/datum/announcer/proc/Format(message, title, subtitle = null)
	var/formatted_message
	var/style = config.style ? "announcement [config.style]" : "announcement"

	formatted_message += "<div class='[style]'>"
	formatted_message += "<h1>[title]</h1>"

	if(subtitle)
		formatted_message += "<h2>[subtitle]</h2>"

	formatted_message += "<p>[message]</p>"

	if(author)
		formatted_message += "<p class='author'> - [html_encode(author)]</p>"

	formatted_message += "</div>"

	return formatted_message

/datum/announcer/proc/Sound(message_sound, receivers)
	if(!message_sound)
		return
	for(var/mob/M in receivers)
		SEND_SOUND(M, message_sound)

/datum/announcer/proc/Log(message, message_title)
	log_game("[key_name(usr)] has made \a [config.log_name]: [message_title] - [message] - [author]")
	message_admins("[key_name_admin(usr)] has made \a [config.log_name].", 1)

/datum/announcement_configuration/event
	default_title = ANNOUNCE_KIND_EVENT
	sound = sound('sound/misc/notice2.ogg')
	style = "minor"

/datum/announcement_configuration/major
	default_title = ANNOUNCE_KIND_MAJOR
	global_announcement = TRUE
	sound = sound('sound/misc/notice2.ogg')

/datum/announcement_configuration/security
	default_title = ANNOUNCE_KIND_SECURITY
	sound = sound('sound/misc/notice2.ogg')
	style = "sec"

/datum/announcement_configuration/minor
	sound = sound('sound/misc/notice2.ogg')
	style = "minor"

/datum/announcement_configuration/requests_console
	style = "minor"
	add_log = TRUE
	sound = sound('sound/misc/notice2.ogg')

/datum/announcement_configuration/comms_console
	default_title = "Priority Announcement"
	add_log = TRUE
	log_name = ANNOUNCE_KIND_PRIORITY
	sound = sound('sound/misc/announce.ogg')
	style = "major"

/datum/announcement_configuration/ai
	default_title = ANNOUNCE_KIND_AI
	add_log = TRUE
	log_name = ANNOUNCE_KIND_AI
	sound = sound('sound/misc/notice2.ogg')
	style = "major"

/datum/announcement_configuration/ptl
	default_title = ANNOUNCE_KIND_PTL
	sound = sound('sound/misc/notice2.ogg')
	style = "major"

