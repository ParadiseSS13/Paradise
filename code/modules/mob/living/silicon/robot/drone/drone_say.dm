/mob/living/silicon/robot/drone/say(var/message)
	if(local_transmit)
		if(src.client)
			if(client.prefs.muted & MUTE_IC)
				to_chat(src, "You cannot send IC messages (muted).")
				return 0
			if(src.client.handle_spam_prevention(message,MUTE_IC))
				return 0

		message = sanitize(message)

		if(stat == 2)
			return say_dead(message)

		if(copytext(message,1,2) == "*")
			return emote(copytext(message,2))

		if(copytext(message,1,2) == ";")
			var/datum/language/L = all_languages["Drone Talk"]
			if(istype(L))
				return L.broadcast(src,trim(copytext(message,2)))

		//Must be concious to speak
		if(stat)
			return 0

		var/list/listeners = hearers(5,src)
		listeners |= src

		for(var/mob/living/silicon/D in listeners)
			if(D.client && D.local_transmit)
				to_chat(D, "<b>[src]</b> transmits, \"[message]\"")

		for(var/mob/M in player_list)
			if(istype(M, /mob/new_player))
				continue
			else if(M.stat == 2 && M.client && M.client.prefs.toggles & CHAT_GHOSTEARS)
				to_chat(M, "<b>[src]</b> transmits, \"[message]\"")
		return 1
	return ..(message, 0)

/mob/living/silicon/robot/drone/whisper_say(var/message, var/datum/language/speaking = null, var/alt_name="", var/verb="whispers")
	say(message) //drones do not get to whisper, only speak normally
	return 1