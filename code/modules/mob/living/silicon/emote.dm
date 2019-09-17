/mob/living/silicon/emote(act, m_type=1, message = null, force)
	var/param = null
	if(findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	//Emote Cooldown System (it's so simple!)
	//handle_emote_CD() located in [code\modules\mob\emote.dm]
	var/on_CD = 0
	act = lowertext(act)
	switch(act)
		//Cooldown-inducing emotes
		if("scream", "screams")
			on_CD = handle_emote_CD(50) //longer cooldown
		if("ping","pings","buzz","buzzs","buzzes","beep","beeps","yes","no", "buzz2")
			//halt is exempt because it's used to stop criminal scum //WHOEVER THOUGHT THAT WAS A GOOD IDEA IS GOING TO GET SHOT.
			on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm
		//Everything else, including typos of the above emotes
		else
			on_CD = 0	//If it doesn't induce the cooldown, we won't check for the cooldown

	if(!force && on_CD == 1)		// Check if we need to suppress the emote attempt.
		return			// Suppress emote, you're still cooling off.
	//--FalseIncarnate

	switch(act)
		if("ping","pings")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> pings[M ? " at [M]" : ""]."
			playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
			m_type = 2

		if("buzz","buzzs","buzzes")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> buzzes[M ? " at [M]" : ""]."
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
			m_type = 2

		if("beep","beeps")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> beeps[M ? " at [M]" : ""]."
			playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 0)
			m_type = 2

		if("yes")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> emits an affirmative blip[M ? " at [M]" : ""]."
			playsound(src.loc, 'sound/machines/synth_yes.ogg', 50, 0)
			m_type = 2

		if("no")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> emits a negative blip[M ? " at [M]" : ""]."
			playsound(src.loc, 'sound/machines/synth_no.ogg', 50, 0)
			m_type = 2

		if("scream", "screams")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> screams[M ? " at [M]" : ""]!"
			playsound(src.loc, 'sound/goonstation/voice/robot_scream.ogg', 80, 0)
			m_type = 2

		if("buzz2")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> emits an irritated buzzing sound[M ? " at [M]" : ""]."
			playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)
			m_type = 2


		if("help")
			to_chat(src, "yes, no, beep, ping, buzz, scream, buzz2")

	..()
