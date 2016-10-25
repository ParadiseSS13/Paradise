var/list/department_radio_keys = list(
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
	  ":-" = "Special Ops",	"#-" = "Special Ops",	".-" = "Special Ops",
	  ":_" = "SyndTeam",	"#_" = "SyndTeam",		"._" = "SyndTeam"
)


var/list/channel_to_radio_key = new
proc/get_radio_key_from_channel(var/channel)
	var/key = channel_to_radio_key[channel]
	if(!key)
		for(var/radio_key in department_radio_keys)
			if(department_radio_keys[radio_key] == channel)
				key = radio_key
				break
		if(!key)
			key = ""
		channel_to_radio_key[channel] = key

	return key

/mob/living/proc/binarycheck()
	return FALSE

/mob/living/proc/get_default_language()
	return default_language

/mob/living/proc/handle_speech_problems(var/message, var/verb)
	var/list/returns[3]
	var/speech_problem_flag = 0
	var/robot = isSynthetic()


	if((HULK in mutations) && health >= 25 && length(message))
		message = "[uppertext(message)]!!!"
		verb = pick("yells","roars","hollers")
		speech_problem_flag = 1

	if(slurring)
		if(robot)
			message = slur(message, list("@", "!", "#", "$", "%", "&", "?"))
		else
			message = slur(message)
		verb = "slurs"
		speech_problem_flag = 1
	if(stuttering)
		if(robot)
			message = robostutter(message)
		else
			message = stutter(message)
		verb = "stammers"
		speech_problem_flag = 1

	if(COMIC in mutations)
		message = "<span class='sans'>[message]</span>"

	if(!IsVocal())
		message = ""
		speech_problem_flag = 1

	returns[1] = message
	returns[2] = verb
	returns[3] = speech_problem_flag
	return returns

/mob/living/proc/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	switch(message_mode)
		if("whisper") //all mobs can whisper by default
			whisper_say(message, speaking, alt_name)
			return 1
	return 0

/mob/living/proc/handle_speech_sound()
	var/list/returns[2]
	returns[1] = null
	returns[2] = null
	return returns


/mob/living/say(var/message, var/datum/language/speaking = null, var/verb = "says", var/alt_name="")
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='danger'>You cannot speak in IC (Muted).</span>")
			return

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
	if(!speaking)
		speaking = parse_language(message)
	if(speaking)
		message = copytext(message, 2 + length(speaking.key))
	else
		speaking = get_default_language()

	// This is broadcast to all mobs with the language,
	// irrespective of distance or anything else.
	if(speaking && (speaking.flags & HIVEMIND))
		speaking.broadcast(src,trim(message))
		return 1

	verb = say_quote(message, speaking)

	if(is_muzzled())
		var/obj/item/clothing/mask/muzzle/G = wear_mask
		if(G.mute) //if the mask is supposed to mute you completely or just muffle you
			to_chat(src, "<span class='danger'>You're muzzled and cannot speak!</span>")
			return
		else
			message = muffledspeech(message)
			verb = "mumbles"

	message = trim_left(message)

	message = handle_autohiss(message, speaking)

	if(speaking && !(speaking.flags & NO_STUTTER))
		var/list/handle_s = handle_speech_problems(message, verb)
		message = handle_s[1]
		verb = handle_s[2]

	if(!message || message == "")
		return 0

	var/list/used_radios = list()
	if(handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name))
		return 1

	var/list/handle_v = handle_speech_sound()
	var/sound/speech_sound = handle_v[1]
	var/sound_vol = handle_v[2]

	var/italics = 0
	var/message_range = world.view

	//speaking into radios
	if(used_radios.len)
		italics = 1
		message_range = 1
		if(speaking)
			message_range = speaking.get_talkinto_msg_range(message)
		var/msg
		if(!speaking || !(speaking.flags & NO_TALK_MSG))
			msg = "<span class='notice'>\The [src] talks into \the [used_radios[1]]</span>"

		if(msg)
			for(var/mob/living/M in hearers(5, src) - src)
				M.show_message(msg)

		if(speech_sound)
			sound_vol *= 0.5


	var/turf/T = get_turf(src)

	//handle nonverbal and sign languages here
	if(speaking)
		if(speaking.flags & NONVERBAL)
			if(prob(30))
				custom_emote(1, "[pick(speaking.signlang_verb)].")

		if(speaking.flags & SIGNLANG)
			return say_signlang(message, pick(speaking.signlang_verb), speaking)

	var/list/listening = list()
	var/list/listening_obj = list()

	if(T)
		//make sure the air can transmit speech - speaker's side
		var/datum/gas_mixture/environment = T.return_air()
		var/pressure = environment ? environment.return_pressure() : 0
		if(pressure < SOUND_MINIMUM_PRESSURE)
			message_range = 1

		if(pressure < ONE_ATMOSPHERE * 0.4) //sound distortion pressure, to help clue people in that the air is thin, even if it isn't a vacuum yet
			italics = 1
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

		for(var/mob/M in player_list)
			if(!M.client)
				continue //skip monkeys and leavers
			if(isnewplayer(M))
				continue
			if(M.stat == DEAD && M.client && (M.client.prefs.toggles & CHAT_GHOSTEARS) && client) // client is so that ghosts don't have to listen to mice
				listening |= M
				continue
			if(get_turf(M) in hearturfs)
				listening |= M

	var/list/speech_bubble_recipients = list()
	var/speech_bubble_test = say_test(message)

	for(var/mob/M in listening)
		M.hear_say(message, verb, speaking, alt_name, italics, src, speech_sound, sound_vol)
		if(M.client)
			speech_bubble_recipients.Add(M.client)
	spawn(0)
		if(loc && !isturf(loc))
			var/atom/A = loc //Non-turf, let it handle the speech bubble
			A.speech_bubble("hR[speech_bubble_test]", A.loc, speech_bubble_recipients)
		else //Turf, leave speech bubbles to the mob
			speech_bubble("h[speech_bubble_test]", src, speech_bubble_recipients)

	for(var/obj/O in listening_obj)
		spawn(0)
			if(O) //It's possible that it could be deleted in the meantime.
				O.hear_talk(src, message, verb, speaking)

	log_say("[name]/[key] : [message]")
	return 1

/mob/living/proc/say_signlang(var/message, var/verb="gestures", var/datum/language/language)
	for(var/mob/O in viewers(src, null))
		O.hear_signlang(message, verb, language, src)
	return 1

/obj/effect/speech_bubble
	var/mob/parent

/mob/living/proc/GetVoice()
	return name

/mob/living/emote(var/act, var/type, var/message) //emote code is terrible, this is so that anything that isn't
	if(stat)	return 0                          //already snowflaked to shit can call the parent and handle emoting sanely

	if(..(act, type, message))
		return 1

	if(act && type && message) //parent call
		log_emote("[name]/[key] : [message]")

		for(var/mob/M in dead_mob_list)
			if(!M.client || istype(M, /mob/new_player))
				continue //skip monkeys, leavers and new players //who the hell knows why new players are in the dead mob list

			if(M.stat == DEAD && (M.client.prefs.toggles & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
				M.show_message(message)

		switch(type)
			if(1) //Visible
				visible_message(message)
				return 1
			if(2) //Audible
				audible_message(message)
				return 1

	else //everything else failed, emote is probably invalid
		if(act == "help")	return //except help, because help is handled individually
		to_chat(src, "\blue Unusable emote '[act]'. Say *help for a list.")

/mob/living/whisper(message as text)
	message = trim_strip_html_properly(message)

	//parse the language code and consume it
	var/datum/language/speaking = parse_language(message)
	if(speaking)
		message = copytext(message, 2 + length(speaking.key))
	else
		speaking = get_default_language()

	// This is broadcast to all mobs with the language,
	// irrespective of distance or anything else.
	if(speaking && (speaking.flags & HIVEMIND))
		speaking.broadcast(src,trim(message))
		return 1

	message = trim_left(message)
	message = handle_autohiss(message, speaking)

	whisper_say(message, speaking)

// for weird circumstances where you're inside an atom that is also you, like pai's
/mob/living/proc/get_whisper_loc()
	return src

/mob/living/proc/whisper_say(var/message, var/datum/language/speaking = null, var/alt_name="", var/verb="whispers")
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='danger'>You cannot speak in IC (Muted).</span>")
			return

	if(stat)
		if(stat == DEAD)
			return say_dead(message)
		return

	if(is_muzzled())
		if(istype(wear_mask, /obj/item/clothing/mask/muzzle/tapegag)) //just for tape
			to_chat(src, "<span class='danger'>Your mouth is taped and you cannot speak!</span>")
		else
			to_chat(src, "<span class='danger'>You're muzzled and cannot speak!</span>")
		return

	var/message_range = 1
	var/eavesdropping_range = 2
	var/watching_range = 5
	var/italics = 1

	var/not_heard //the message displayed to people who could not hear the whispering
	if(speaking)
		if(speaking.whisper_verb)
			verb = speaking.whisper_verb
			not_heard = "[verb] something"
		else
			var/adverb = pick("quietly", "softly")
			verb = "[speaking.speech_verb] [adverb]"
			not_heard = "[speaking.speech_verb] something [adverb]"
	else
		not_heard = "[verb] something"

	message = trim(message)

	var/speech_problem_flag = 0
	var/list/handle_s = handle_speech_problems(message, verb)
	message = handle_s[1]
	verb = handle_s[2]
	speech_problem_flag = handle_s[3]
	if(verb == "yells loudly")
		verb = "slurs emphatically"

	else if(speech_problem_flag)
		var/adverb = pick("quietly", "softly")
		verb = "[verb] [adverb]"

	if(!message)
		return

	var/atom/whisper_loc = get_whisper_loc()
	var/list/listening = hearers(message_range, whisper_loc)
	listening |= src

	//ghosts
	for(var/mob/M in dead_mob_list)	//does this include players who joined as observers as well?
		if(!M.client)
			continue
		if(M.stat == DEAD && M.client && (M.client.prefs.toggles & CHAT_GHOSTEARS))
			listening |= M

	//Pass whispers on to anything inside the immediate listeners.
	for(var/mob/L in listening)
		for(var/mob/C in L.contents)
			if(isliving(C))
				listening += C

	//pass on the message to objects that can hear us.
	for(var/obj/O in view(message_range, whisper_loc))
		spawn(0)
			if(O)
				O.hear_talk(src, message, verb, speaking)

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
		M.hear_say(message, verb, speaking, alt_name, italics, src)
		if(M.client)
			speech_bubble_recipients.Add(M.client)

	if(eavesdropping.len)
		var/new_message = stars(message)	//hopefully passing the message twice through stars() won't hurt... I guess if you already don't understand the language, when they speak it too quietly to hear normally you would be able to catch even less.
		for(var/mob/M in eavesdropping)
			M.hear_say(new_message, verb, speaking, alt_name, italics, src)
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

	log_whisper("[name]/[key] : [message]")
	return 1

/mob/living/speech_bubble(var/bubble_state = "",var/bubble_loc = src, var/list/bubble_recipients = list())
	var/image/I = image('icons/mob/talk.dmi', bubble_loc, bubble_state, MOB_LAYER + 1)
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	flick_overlay(I, bubble_recipients, 30)
