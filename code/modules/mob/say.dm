
/mob/proc/say()
	return

/mob/verb/whisper(message as text)
	set name = "Whisper"
	set category = "IC"
	return

/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"

	//Let's try to make users fix their errors - we try to detect single, out-of-place letters and 'unintended' words
	/*
	var/first_letter = copytext(message,1,2)
	if((copytext(message,2,3) == " " && first_letter != "I" && first_letter != "A" && first_letter != ";") || cmptext(copytext(message,1,5), "say ") || cmptext(copytext(message,1,4), "me ") || cmptext(copytext(message,1,6), "looc ") || cmptext(copytext(message,1,5), "ooc ") || cmptext(copytext(message,2,6), "say "))
		var/response = alert(usr, "Do you really want to say this using the *say* verb?\n\n[message]\n", "Confirm your message", "Yes", "Edit message", "No")
		if(response == "Edit message")
			message = input(usr, "Please edit your message carefully:", "Edit message", message)
			if(!message)
				return
		else if(response == "No")
			return
	*/

	set_typing_indicator(0)
	usr.say(message)


/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"

	message = strip_html_properly(message)

	set_typing_indicator(0)
	if(use_me)
		custom_emote(usr.emote_type, message)
	else
		usr.emote(message)


/mob/proc/say_dead(var/message)
	if(!(client && client.holder))
		if(!config.dsay_allowed)
			to_chat(src, "<span class='danger'>Deadchat is globally muted.</span>")
			return

	if(client && !(client.prefs.toggles & CHAT_DEAD))
		to_chat(usr, "<span class='danger'>You have deadchat muted.</span>")
		return

	say_dead_direct("[pick("complains", "moans", "whines", "laments", "blubbers", "salts")], <span class='message'>\"[message]\"</span>", src)

/mob/proc/say_understands(var/mob/other, var/datum/language/speaking = null)
	if(stat == DEAD)
		return 1

	//Universal speak makes everything understandable, for obvious reasons.
	if(universal_speak || universal_understand)
		return 1

	//Languages are handled after.
	if(!speaking)
		if(!other)
			return 1
		if(other.universal_speak)
			return 1
		if(isAI(src) && ispAI(other))
			return 1
		if(istype(other, src.type) || istype(src, other.type))
			return 1
		return 0

	if(speaking.flags & INNATE)
		return 1

	//Language check.
	for(var/datum/language/L in languages)
		if(speaking.name == L.name)
			return 1

	return 0


/mob/proc/say_quote(var/message, var/datum/language/speaking = null)
	var/verb = "says"
	var/ending = copytext(message, length(message))

	if(speaking)
		verb = speaking.get_spoken_verb(ending)
	else
		if(ending == "!")
			verb = pick("exclaims", "shouts", "yells")
		else if(ending == "?")
			verb = "asks"
	return verb


/mob/proc/emote(var/act, var/type, var/message)
	if(act == "me")
		return custom_emote(type, message)


/mob/proc/get_ear()
	// returns an atom representing a location on the map from which this
	// mob can hear things

	// should be overloaded for all mobs whose "ear" is separate from their "mob"

	return get_turf(src)

/mob/proc/say_test(var/text)
	var/ending = copytext(text, length(text))
	if(ending == "?")
		return "1"
	else if(ending == "!")
		return "2"
	return "0"

//parses the message mode code (e.g. :h, :w) from text, such as that supplied to say.
//returns the message mode string or null for no message mode.
//standard mode is the mode returned for the special ';' radio code.
/mob/proc/parse_message_mode(var/message, var/standard_mode = "headset")
	if(length(message) >= 1 && copytext(message, 1, 2) == ";")
		return standard_mode

	if(length(message) >= 2)
		var/channel_prefix = copytext(message, 1 ,3)
		return department_radio_keys[channel_prefix]

	return null

//parses the language code (e.g. :j) from text, such as that supplied to say.
//returns the language object only if the code corresponds to a language that src can speak, otherwise null.
/mob/proc/parse_language(var/message)
	var/prefix = copytext(message, 1, 2)
	if(length(message) >= 1 && prefix == "!")
		return all_languages["Noise"]

	if(length(message) >= 2)
		var/language_prefix = trim_right(lowertext(copytext(message, 1 ,4)))
		var/datum/language/L = language_keys[language_prefix]
		if(can_speak(L))
			return L

	return null
