/mob/living/carbon/alien/larva/emote(act, m_type = 1, message = null, force)
	var/param = null
	if(findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))
	var/muzzled = is_muzzled()
	act = lowertext(act)
	switch(act)
		if("me")
			if(silent)
				return
			if(src.client)
				if(client.prefs.muted & MUTE_IC)
					to_chat(src, "<span class='warning'>You cannot send IC messages (muted).</span>")
					return
				if(src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if(stat)
				return
			if(!(message))
				return
			return custom_emote(m_type, message)

		if("custom")
			return custom_emote(m_type, message)
		if("sign")
			if(!src.restrained())
				message = text("signs[].", (text2num(param) ? text(" the number []", text2num(param)) : null))
				m_type = 1
		if("burp")
			if(!muzzled)
				message = "burps."
				m_type = 2
		if("scratch")
			if(!src.restrained())
				message = "scratches."
				m_type = 1
		if("whimper")
			if(!muzzled)
				message = "whimpers."
				m_type = 2
//		if("roar")
//			if(!muzzled)
//				message = "roars." Commenting out since larva shouldn't roar /N
//				m_type = 2
		if("tail")
			message = "waves its tail."
			m_type = 1
		if("gasp")
			message = "gasps."
			m_type = 2
		if("shiver")
			message = "shivers."
			m_type = 2
		if("drool")
			message = "drools."
			m_type = 1
		if("scretch")
			if(!muzzled)
				message = "scretches."
				m_type = 2
		if("choke")
			message = "chokes."
			m_type = 2
		if("moan")
			message = "moans!"
			m_type = 2
		if("nod")
			message = "nods its head."
			m_type = 1
//		if("sit")
//			message = "sits down." //Larvan can't sit down, /N
//			m_type = 1
		if("sway")
			message = "sways around dizzily."
			m_type = 1
		if("sulk")
			message = "sulks down sadly."
			m_type = 1
		if("twitch")
			message = "twitches violently."
			m_type = 1
		if("dance")
			if(!src.restrained())
				message = "dances around happily."
				m_type = 1
		if("roll")
			if(!src.restrained())
				message = "rolls."
				m_type = 1
		if("shake")
			message = "shakes its head."
			m_type = 1
		if("gnarl")
			if(!muzzled)
				message = "gnarls and shows its teeth.."
				m_type = 2
		if("jump")
			message = "jumps!"
			m_type = 1
		if("hiss_")
			message = "hisses softly."
			m_type = 1
		if("collapse")
			Paralyse(2)
			message = "collapses!"
			m_type = 2
		if("help")
			to_chat(src, "burp, choke, collapse, dance, drool, gasp, shiver, gnarl, jump, moan, nod, roll, scratch,\nscretch, shake, sign-#, sulk, sway, tail, twitch, whimper")
		else
			to_chat(src, text("Invalid Emote: []", act))
	if((message && src.stat == 0))
		add_emote_logs(src, message)
		if(m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(703)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(746)
	return
