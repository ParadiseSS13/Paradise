GLOBAL_LIST_INIT(department_radio_keys, list(
	  ":r" = "right ear",	"#r" = "right ear",		".r" = "right ear",
	  ":l" = "left ear",	"#l" = "left ear",		".l" = "left ear",
	  ":i" = "intercom",	"#i" = "intercom",		".i" = "intercom",
	  ":h" = "department",	"#h" = "department",	".h" = "department",
	  ":+" = "special",		"#+" = "special",		".+" = "special", //activate radio-specific special functions
	  ":c" = "Command",		"#c" = "Command",		".c" = "Command",
	  ":n" = "Science",		"#n" = "Science",		".n" = "Science",
	  ":m" = "Medical",		"#m" = "Medical",		".m" = "Medical",
	  ":e" = "Engineering", "#e" = "Engineering",	".e" = "Engineering",
	  ":s" = "Security",	"#s" = "Security",		".s" = "Security",
	  ":w" = "whisper",		"#w" = "whisper",		".w" = "whisper",
	  ":t" = "Syndicate",	"#t" = "Syndicate",		".t" = "Syndicate",
	  ":u" = "Supply",		"#u" = "Supply",		".u" = "Supply",
	  ":z" = "Service",		"#z" = "Service",		".z" = "Service",
	  ":p" = "AI Private",	"#p" = "AI Private",	".p" = "AI Private",
	  ":x" = "cords",		"#x" = "cords",			".x" = "cords",

	  ":R" = "right ear",	"#R" = "right ear",		".R" = "right ear",
	  ":L" = "left ear",	"#L" = "left ear",		".L" = "left ear",
	  ":I" = "intercom",	"#I" = "intercom",		".I" = "intercom",
	  ":H" = "department",	"#H" = "department",	".H" = "department",
	  ":C" = "Command",		"#C" = "Command",		".C" = "Command",
	  ":N" = "Science",		"#N" = "Science",		".N" = "Science",
	  ":M" = "Medical",		"#M" = "Medical",		".M" = "Medical",
	  ":E" = "Engineering",	"#E" = "Engineering",	".E" = "Engineering",
	  ":S" = "Security",	"#S" = "Security",		".S" = "Security",
	  ":W" = "whisper",		"#W" = "whisper",		".W" = "whisper",
	  ":T" = "Syndicate",	"#T" = "Syndicate",		".T" = "Syndicate",
	  ":U" = "Supply",		"#U" = "Supply",		".U" = "Supply",
	  ":Z" = "Service",		"#Z" = "Service",		".Z" = "Service",
	  ":P" = "AI Private",	"#P" = "AI Private",	".P" = "AI Private",
	  ":$" = "Response Team", "#$" = "Response Team", ".$" = "Response Team",
	  ":-" = "Special Ops",	"#-" = "Special Ops",	".-" = "Special Ops",
	  ":_" = "SyndTeam",	"#_" = "SyndTeam",		"._" = "SyndTeam",
	  ":X" = "cords",		"#X" = "cords",			".X" = "cords"
))

GLOBAL_LIST_EMPTY(channel_to_radio_key)

proc/get_radio_key_from_channel(var/channel)
	var/key = GLOB.channel_to_radio_key[channel]
	if(!key)
		for(var/radio_key in GLOB.department_radio_keys)
			if(GLOB.department_radio_keys[radio_key] == channel)
				key = radio_key
				break
		if(!key)
			key = ""
		GLOB.channel_to_radio_key[channel] = key

	return key

/mob/living/proc/binarycheck()
	return FALSE

/mob/proc/get_default_language()
	return null

/mob/living/get_default_language()
	return default_language

/mob/living/proc/handle_speech_problems(list/message_pieces, var/verb)
	var/robot = isSynthetic()
	for(var/datum/multilingual_say_piece/S in message_pieces)
		if(S.speaking && S.speaking.flags & NO_STUTTER)
			continue

		if((HULK in mutations) && health >= 25)
			S.message = "[uppertext(S.message)]!!!"
			verb = pick("yells", "roars", "hollers")

		if(slurring)
			if(robot)
				S.message = slur(S.message, list("@", "!", "#", "$", "%", "&", "?"))
			else
				S.message = slur(S.message)
			verb = "slurs"

		if(stuttering)
			if(robot)
				S.message = robostutter(S.message)
			else
				S.message = stutter(S.message)
			verb = "stammers"

		if(cultslurring)
			S.message = cultslur(S.message)
			verb = "slurs"

		if(!IsVocal())
			S.message = ""
	return list("verb" = verb)

/mob/living/proc/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	switch(message_mode)
		if("whisper") //all mobs can whisper by default
			whisper_say(message_pieces)
			return 1
	return 0

/mob/living/proc/handle_speech_sound()
	var/list/returns[3]
	returns[1] = null
	returns[2] = null
	returns[3] = null
	return returns


/mob/living/say(var/message, var/verb = "says", var/sanitize = TRUE, var/ignore_speech_problems = FALSE, var/ignore_atmospherics = FALSE)
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='danger'>You cannot speak in IC (Muted).</span>")
			return

	if(sanitize)
		message = trim_strip_html_properly(message)

	if(stat)
		if(stat == DEAD)
			return say_dead(message)
		return

	var/message_mode = parse_message_mode(message, "headset")

	if(copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2))

	//parse the radio code and consume it
	if(message_mode)
		if(message_mode == "headset")
			message = copytext(message, 2)	//it would be really nice if the parse procs could do this for us.
		else
			message = copytext(message, 3)

	message = trim_left(message)

	//parse the language code and consume it
	var/list/message_pieces = parse_languages(message)
	if(istype(message_pieces, /datum/multilingual_say_piece)) // Little quirk to just easily deal with HIVEMIND languages
		var/datum/multilingual_say_piece/S = message_pieces // Yay BYOND's hilarious typecasting
		S.speaking.broadcast(src, S.message)
		return 1


	if(!LAZYLEN(message_pieces))
		log_runtime(EXCEPTION("Message failed to generate pieces. [message] - [json_encode(message_pieces)]"))
		return 0

	if(message_mode == "cords")
		if(iscarbon(src))
			var/mob/living/carbon/C = src
			var/obj/item/organ/internal/vocal_cords/V = C.get_int_organ(/obj/item/organ/internal/vocal_cords)
			if(V && V.can_speak_with())
				C.say(V.handle_speech(message), sanitize = FALSE, ignore_speech_problems = TRUE, ignore_atmospherics = TRUE)
				V.speak_with(message) //words come before actions
		return 1

	var/datum/multilingual_say_piece/first_piece = message_pieces[1]
	verb = say_quote(message, first_piece.speaking)

	if(is_muzzled())
		var/obj/item/clothing/mask/muzzle/G = wear_mask
		if(G.mute == MUZZLE_MUTE_ALL) //if the mask is supposed to mute you completely or just muffle you
			to_chat(src, "<span class='danger'>You're muzzled and cannot speak!</span>")
			return
		else if(G.mute == MUZZLE_MUTE_MUFFLE)
			muffledspeech_all(message_pieces)
			verb = "mumbles"

	if(!ignore_speech_problems)
		var/list/hsp = handle_speech_problems(message_pieces, verb)
		verb = hsp["verb"]


	var/list/used_radios = list()
	if(handle_message_mode(message_mode, message_pieces, verb, used_radios))
		return 1


	var/list/handle_v = handle_speech_sound()
	var/sound/speech_sound = handle_v[1]
	var/sound_vol = handle_v[2]
	var/sound_frequency = handle_v[3]

	var/italics = 0
	var/message_range = world.view

	//speaking into radios
	if(used_radios.len)
		italics = 1
		message_range = 1
		if(first_piece.speaking)
			message_range = first_piece.speaking.get_talkinto_msg_range(message)

		var/msg
		if(!first_piece.speaking || !(first_piece.speaking.flags & NO_TALK_MSG))
			msg = "<span class='notice'>[src] talks into [used_radios[1]]</span>"

		if(msg)
			for(var/mob/living/M in hearers(5, src) - src)
				M.show_message(msg)

		if(speech_sound)
			sound_vol *= 0.5


	var/turf/T = get_turf(src)
	var/list/listening = list()
	var/list/listening_obj = list()

	if(T)
		//make sure the air can transmit speech - speaker's side
		var/datum/gas_mixture/environment = T.return_air()
		var/pressure = environment ? environment.return_pressure() : 0
		if(!ignore_atmospherics)
			if(pressure < SOUND_MINIMUM_PRESSURE)
				message_range = 1

			if(pressure < ONE_ATMOSPHERE * 0.4) //sound distortion pressure, to help clue people in that the air is thin, even if it isn't a vacuum yet
				italics = TRUE
				sound_vol *= 0.5 //muffle the sound a bit, so it's like we're actually talking through contact

		var/list/hear = hear(message_range, T)
		var/list/hearturfs = list()

		for(var/I in hear)
			if(ismob(I))
				var/mob/M = I
				listening += M
				hearturfs += get_turf(M)
				for(var/obj/O in M.contents)
					listening_obj |= O
			if(isobj(I))
				var/obj/O = I
				hearturfs += get_turf(O)
				listening_obj |= O

		for(var/mob/M in GLOB.player_list)
			if(!M.client)
				continue

			if(isnewplayer(M))
				continue

			if(isobserver(M))
				if(M.get_preference(CHAT_GHOSTEARS) && client) // The client check is so that ghosts don't have to listen to mice.
					listening |= M
					continue

				if(message_range < world.view && (get_dist(T, M) <= world.view))
					listening |= M
					continue

			if(get_turf(M) in hearturfs)
				listening |= M

	var/list/speech_bubble_recipients = list()
	var/speech_bubble_test = say_test(message)

	for(var/mob/M in listening)
		M.hear_say(message_pieces, verb, italics, src, speech_sound, sound_vol, sound_frequency)
		if(M.client)
			speech_bubble_recipients.Add(M.client)
	spawn(0)
		if(loc && !isturf(loc))
			var/atom/A = loc //Non-turf, let it handle the speech bubble
			A.speech_bubble("hR[speech_bubble_test]", A, speech_bubble_recipients)
		else //Turf, leave speech bubbles to the mob
			speech_bubble("h[speech_bubble_test]", src, speech_bubble_recipients)

	for(var/obj/O in listening_obj)
		spawn(0)
			if(O) //It's possible that it could be deleted in the meantime.
				O.hear_talk(src, message_pieces, verb)

	//Log of what we've said, plain message, no spans or junk
	say_log += message
	create_log(SAY_LOG, message) // TODO after #13047: Include the channel
	log_say(message, src)
	return 1

/obj/effect/speech_bubble
	var/mob/parent

/mob/living/proc/GetVoice()
	return name

/mob/living/emote(act, type, message, force) //emote code is terrible, this is so that anything that isn't already snowflaked to shit can call the parent and handle emoting sanely
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='danger'>You cannot speak in IC (Muted).</span>")
			return

	if(stat)
		return 0

	if(..())
		return 1

	if(act && type && message) //parent call
		log_emote(message, src)

		for(var/mob/M in GLOB.dead_mob_list)
			if(!M.client)
				continue //skip monkeys and leavers

			if(isnewplayer(M))
				continue

			if(isobserver(M) && M.get_preference(CHAT_GHOSTSIGHT) && !(M in viewers(src, null)) && client) // The client check makes sure people with ghost sight don't get spammed by simple mobs emoting.
				M.show_message(message)

		switch(type)
			if(1) //Visible
				visible_message(message)
				return 1
			if(2) //Audible
				audible_message(message)
				return 1

	else //everything else failed, emote is probably invalid
		if(act == "help")
			return //except help, because help is handled individually
		to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")

/mob/living/whisper(message as text)
	message = trim_strip_html_properly(message)

	//parse the language code and consume it
	var/list/message_pieces = parse_languages(message)
	if(istype(message_pieces, /datum/multilingual_say_piece)) // Little quirk to just easily deal with HIVEMIND languages
		var/datum/multilingual_say_piece/S = message_pieces // Yay BYOND's hilarious typecasting
		S.speaking.broadcast(src, S.message)
		return 1

	whisper_say(message_pieces)

// for weird circumstances where you're inside an atom that is also you, like pai's
/mob/living/proc/get_whisper_loc()
	return src

/mob/living/proc/whisper_say(list/message_pieces, verb = "whispers")
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='danger'>You cannot speak in IC (Muted).</span>")
			return

	if(stat)
		if(stat == DEAD)
			return say_dead(message_pieces)
		return

	if(is_muzzled())
		if(istype(wear_mask, /obj/item/clothing/mask/muzzle/tapegag)) //just for tape
			to_chat(src, "<span class='danger'>Your mouth is taped and you cannot speak!</span>")
		else
			to_chat(src, "<span class='danger'>You're muzzled and cannot speak!</span>")
		return

	var/message = multilingual_to_message(message_pieces)

	say_log += "whisper: [message]"
	log_whisper(message, src)
	create_log(SAY_LOG, "WHISPER: [message]")
	var/message_range = 1
	var/eavesdropping_range = 2
	var/watching_range = 5
	var/italics = 1
	var/adverb_added = FALSE
	var/not_heard //the message displayed to people who could not hear the whispering

	var/datum/multilingual_say_piece/first_piece = message_pieces[1]
	if(first_piece.speaking)
		if(first_piece.speaking.whisper_verb)
			verb = first_piece.speaking.whisper_verb
			not_heard = "[verb] something"
		else
			var/adverb = pick("quietly", "softly")
			adverb_added = TRUE
			verb = "[first_piece.speaking.speech_verb] [adverb]"
			not_heard = "[first_piece.speaking.speech_verb] something [adverb]"
	else
		not_heard = "[verb] something"

	var/list/hsp = handle_speech_problems(message_pieces, verb)
	verb = hsp["verb"]
	if(verb == "yells loudly")
		verb = "slurs emphatically"
	else if(!adverb_added)
		var/adverb = pick("quietly", "softly")
		verb = "[verb] [adverb]"

	var/atom/whisper_loc = get_whisper_loc()
	var/list/listening = hear(message_range, whisper_loc)
	listening |= src

	var/list/hearturfs = list()

	// Pass whispers on to anything inside the immediate listeners.
	// This comes before the ghosts do so that ghosts don't act as whisper relays
	for(var/atom/L in listening)
		if(ismob(L))
			for(var/mob/C in L.contents)
				if(isliving(C))
					listening += C
			hearturfs += get_turf(L)
		if(isobj(L))
			hearturfs += get_turf(L)

	// Loop through all players to see if they need to hear it.
	for(var/mob/M in GLOB.player_list)
		if(!M.client)
			continue

		if(isnewplayer(M))
			continue

		if(isobserver(M))
			if(M.get_preference(CHAT_GHOSTEARS)) // The client check is so that ghosts don't have to listen to mice.
				listening |= M
				continue

			if(message_range < world.view && (get_dist(whisper_loc, M) <= world.view))
				listening |= M
				continue

		if(get_turf(M) in hearturfs)
			listening |= M

	//pass on the message to objects that can hear us.
	for(var/obj/O in view(message_range, whisper_loc))
		spawn(0)
			if(O)
				O.hear_talk(src, message_pieces, verb)

	var/list/eavesdropping = hearers(eavesdropping_range, whisper_loc)
	eavesdropping -= src
	eavesdropping -= listening

	var/list/watching = hearers(watching_range, whisper_loc)
	watching  -= src
	watching  -= listening
	watching  -= eavesdropping

	//now mobs
	var/list/speech_bubble_recipients = list()
	var/speech_bubble_test = say_test(message)

	for(var/mob/M in listening)
		M.hear_say(message_pieces, verb, italics, src)
		if(M.client)
			speech_bubble_recipients.Add(M.client)

	if(eavesdropping.len)
		stars_all(message_pieces)	//hopefully passing the message twice through stars() won't hurt... I guess if you already don't understand the language, when they speak it too quietly to hear normally you would be able to catch even less.
		for(var/mob/M in eavesdropping)
			M.hear_say(message_pieces, verb, italics, src)
			if(M.client)
				speech_bubble_recipients.Add(M.client)

	spawn(0)
		var/image/I = image('icons/mob/talk.dmi', src, "h[speech_bubble_test]", MOB_LAYER + 1)
		I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
		flick_overlay(I, speech_bubble_recipients, 30)

	if(watching.len)
		var/rendered = "<span class='game say'><span class='name'>[name]</span> [not_heard].</span>"
		for(var/mob/M in watching)
			M.show_message(rendered, 2)

	return 1

/mob/living/speech_bubble(var/bubble_state = "",var/bubble_loc = src, var/list/bubble_recipients = list())
	var/image/I = image('icons/mob/talk.dmi', bubble_loc, bubble_state, MOB_LAYER + 1)
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	flick_overlay(I, bubble_recipients, 30)
