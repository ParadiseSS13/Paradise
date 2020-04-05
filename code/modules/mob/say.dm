
#define ILLEGAL_CHARACTERS_LIST list("<" = "", ">" = "", \
	"\[" = "", "]" = "", "{" = "", "}" = "")

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
	message = replace_characters(message, ILLEGAL_CHARACTERS_LIST)
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


/mob/proc/emote(act, type, message, force)
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
		return GLOB.department_radio_keys[channel_prefix]

	return null

/datum/multilingual_say_piece
	var/datum/language/speaking = null
	var/message = ""

/datum/multilingual_say_piece/New(datum/language/new_speaking, new_message)
	. = ..()
	speaking = new_speaking
	if(new_message)
		message = new_message

/mob/proc/find_valid_prefixes(message)
	var/list/prefixes = list() // [["Common", start, end], ["Gutter", start, end]]
	for(var/i in 1 to length(message))
		var/selection = trim_right(lowertext(copytext(message, i, i + 3)))
		var/datum/language/L = GLOB.language_keys[selection]
		if(L != null && can_speak_language(L)) // What the fuck... remove the L != null check if you ever find out what the fuck is adding `null` to the languages list on absolutely random mobs... seriously what the hell...
			prefixes[++prefixes.len] = list(L, i, i + length(selection))
		else if(!L && i == 1)
			prefixes[++prefixes.len] = list(get_default_language(), i, i)
		else
	return prefixes

/proc/strip_prefixes(message)
	. = ""
	var/last_index = 1
	for(var/i in 1 to length(message))
		var/selection = trim_right(lowertext(copytext(message, i, i + 3)))
		var/datum/language/L = GLOB.language_keys[selection]
		if(L)
			. += copytext(message, last_index, i)
			last_index = i + 3
		if(i + 1 > length(message))
			. += copytext(message, last_index)

// this returns a structured message with language sections
// list(/datum/multilingual_say_piece(common, "hi"), /datum/multilingual_say_piece(farwa, "squik"), /datum/multilingual_say_piece(common, "meow!"))
/mob/proc/parse_languages(message)
	. = list()

	// Noise language is a snowflake
	if(copytext(message, 1, 2) == "!" && length(message) > 1)
		return list(new /datum/multilingual_say_piece(GLOB.all_languages["Noise"], trim(strip_prefixes(copytext(message, 2)))))

	// Scan the message for prefixes
	var/list/prefix_locations = find_valid_prefixes(message)
	if(!LAZYLEN(prefix_locations)) // There are no prefixes... or at least, no _valid_ prefixes.
		. += new /datum/multilingual_say_piece(get_default_language(), trim(strip_prefixes(message))) // So we'll just strip those pesky things and still make the message.

	for(var/i in 1 to length(prefix_locations))
		var/current = prefix_locations[i] // ["Common", keypos]

		// There are a few things that will make us want to ignore all other languages in - namely, HIVEMIND languages.
		var/datum/language/L = current[1]
		if(L && L.flags & HIVEMIND)
			. = new /datum/multilingual_say_piece(L, trim(strip_prefixes(message)))
			break

		if(i + 1 > length(prefix_locations)) // We are out of lookaheads, that means the rest of the message is in cur lang
			var/spoke_message = handle_autohiss(trim(copytext(message, current[3])), L)
			. += new /datum/multilingual_say_piece(current[1], spoke_message)
		else
			var/next = prefix_locations[i + 1] // We look ahead at the next message to see where we need to stop.
			var/spoke_message = handle_autohiss(trim(copytext(message, current[3], next[2])), L)
			. += new /datum/multilingual_say_piece(current[1], spoke_message)

/* These are here purely because it would be hell to try to convert everything over to using the multi-lingual system at once */
/proc/message_to_multilingual(message, datum/language/speaking = null)
	. = list(new /datum/multilingual_say_piece(speaking, message))

/proc/multilingual_to_message(list/message_pieces)
	. = ""
	for(var/datum/multilingual_say_piece/S in message_pieces)
		. += S.message + " "
	. = trim_right(.)

#undef ILLEGAL_CHARACTERS_LIST
