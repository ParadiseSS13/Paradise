/mob/living/silicon/pai/emote(var/act,var/m_type=1,var/message = null)
	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	//Emote Cooldown System (it's so simple!)
	// proc/handle_emote_CD() located in [code\modules\mob\emote.dm]
	var/on_CD = 0
	switch(act)
		//Cooldown-inducing emotes
		if("ping","buzz")
			on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm
		//Everything else, including typos of the above emotes
		else
			on_CD = 0	//If it doesn't induce the cooldown, we won't check for the cooldown

	if(on_CD == 1)		// Check if we need to suppress the emote attempt.
		return			// Suppress emote, you're still cooling off.
	//--FalseIncarnate

	switch(act)
		if ("me")
			if (src.client)
				if(client.prefs.muted & MUTE_IC)
					src << "You cannot send IC messages (muted)."
					return
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			else
				return custom_emote(m_type, message)

		if ("custom")
			return custom_emote(m_type, message)

		if("ping")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> pings at [param]."
			else
				message = "<B>[src]</B> pings."
			playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
			m_type = 1

		if("buzz")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> buzzes at [param]."
			else
				message = "<B>[src]</B> buzzes."
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
			m_type = 1

		if ("help")
			src << "ping, \nbuzz."
		else
			src << "\blue Unusable emote '[act]'. Say *help for a list."

	if ((message && src.stat == 0))
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
	return