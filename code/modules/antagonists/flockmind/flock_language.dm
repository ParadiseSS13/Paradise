/datum/language/flock
	name = "Symphonic"
	speech_verb = "caws"
	space_chance = 60
	key = "f"
	flags = RESTRICTED | HIVEMIND | NOLIBRARIAN | NOBABEL | NO_STUTTER
	colour = "flocksay"
	syllables = list("c#aw", "kr%k", "c@rk", "ka~w", "cr!k", "sk^a", "r#aw", "c*rr", "ka%x", "t~ch", "gr!k", "c&aw", "k!rr", "ch#k", "ra%k", "sk@w", "tr^k", "c~ra", "kw!p", "z#aw", "cl%k", "r@rk", "sh^k", "k~ra", "v!aw")

/datum/language/flock/get_spoken_verb(msg_end)
	switch(msg_end)
		if("!")
			return pick(exclaim_verbs)
		if("?")
			return ask_verb
	return pick("sings", "clicks", "whistles", "intones", "transmits", "submits", "uploads", "caws")

/datum/language/flock/format_message(message)
	return SPAN_FLOCKSAY_GRADIENT("[get_spoken_verb(message)] \"[message]\"")

/datum/language/flock/broadcast(atom/speaker, message, speaker_mask, involuntary = FALSE)
	var/log_message = "(FLOCK) [message]"
	if(ismob(speaker))
		var/mob/M = speaker
		log_say(log_message, speaker)
		M.create_log(SAY_LOG, log_message)

	var/list/message_start
	var/list/message_body = list(format_message(message))

	if(!speaker)
		message_start = list("<i><span class='game say'>[name]</i>: ", SPAN_FLOCKSAY_GRADIENT("System"))
	else if(!ismob(speaker))
		message_start = list("<i><span class='game say'>[name]</i>: ", SPAN_FLOCKSAY_GRADIENT("[speaker.name]"))
	else if(isflockcontroller(speaker))
		var/mob/speaking_mob = speaker
		message_start = list("<i><font size=4><span class='game say'>[name]</i>: ", SPAN_FLOCKSAY_GRADIENT("[isflockmind(speaker) ? "" : "Flocktrace "][speaking_mob.real_name]"))
		message_body += "</font>"
	else if(isflockworker(speaker))
		var/mob/speaking_mob = speaker
		message_start = list("<i><span class='game say'>[name]</i>: ", SPAN_FLOCKSAY_GRADIENT("Drone [speaking_mob.real_name]"))

	for(var/mob/M in GLOB.dead_mob_list)
		if(!isnewplayer(M) && !isbrain(M) && speaker)
			var/list/message_start_dead = list("<i><span class='game say'>[name], [SPAN_NAME("[speaker.name] ([ghost_follow_link(speaker, ghost=M)])")]")
			var/list/dead_message = message_start_dead + message_body
			M.show_message(dead_message.Join(" "), 2)

	if(speaker && !isflockcontroller(speaker))
		var/scrambled = SPAN_FLOCKSAY_GRADIENT(scramble(message))
		var/living_msg = "[speaker.name] [get_spoken_verb(message)] \"[scrambled]\""
		for(var/mob/M in hearers(5, get_turf(speaker)))
			M.show_message(living_msg, 2)
			if(M.client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT && ismob(speaker))
				var/mob/speaking_mob = speaker
				M.create_chat_message(locateUID(speaking_mob.runechat_msg_location), scrambled)

	for(var/mob/F in GLOB.alive_mob_list)
		if(!isflockmob(F))
			continue
		var/list/final_message = message_start + message_body
		F.show_message(final_message.Join(" "), 2)
		if(F.client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT && ismob(speaker))
			var/mob/speaking_mob = speaker
			F.create_chat_message(locateUID(speaking_mob.runechat_msg_location), message)

	var/list/silicon_message_start = list("<i><span class='game say'>Robot Talk, [SPAN_NAME("Strange Static")]")
	var/silicon_message_content = Gibberish(message, 70, replace_rate = 50)
	var/silicon_message = SPAN_ROBOT(silicon_message_content)
	var/list/final_message_silicon = silicon_message_start + silicon_message
	if(involuntary || !prob(30))
		return
	for(var/mob/living/silicon/S in GLOB.alive_mob_list)
		if(!S.binarycheck())
			continue
		S.show_message(final_message_silicon.Join(" "), 2)
		if(isflockworker(speaker) && S.client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT && ismob(speaker))
			var/mob/speaking_mob = speaker
			S.create_chat_message(locateUID(speaking_mob.runechat_msg_location), silicon_message_content)
