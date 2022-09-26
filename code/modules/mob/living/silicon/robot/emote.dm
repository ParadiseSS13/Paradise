/mob/living/silicon/robot/emote(act, m_type=1, message = null, force)
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
		if("law","flip","flips","halt")		//halt is exempt because it's used to stop criminal scum //WHOEVER THOUGHT THAT WAS A GOOD IDEA IS GOING TO GET SHOT.
			on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm
		//Everything else, including typos of the above emotes
		else
			on_CD = 0	//If it doesn't induce the cooldown, we won't check for the cooldown

	if(!force && on_CD == 1)		// Check if we need to suppress the emote attempt.
		return			// Suppress emote, you're still cooling off.
	//--FalseIncarnate

	switch(act)

		if("salute","salutes")
			if(!src.buckled)
				var/M = null
				if(param)
					for(var/mob/A in view(null, null))
						if(param == A.name)
							M = A
							break
				if(!M)
					param = null

				if(param)
					message = "salutes to [param]."
				else
					message = "salutes."
			m_type = 1
		if("bow","bows")
			if(!src.buckled)
				var/M = null
				if(param)
					for(var/mob/A in view(null, null))
						if(param == A.name)
							M = A
							break
				if(!M)
					param = null

				if(param)
					message = "bows to [param]."
				else
					message = "bows."
			m_type = 1

		if("clap","claps")
			if(!src.restrained())
				message = "claps."
				m_type = 2
		if("flap","flaps")
			if(!src.restrained())
				message = "flaps its wings."
				m_type = 2

		if("aflap","aflaps")
			if(!src.restrained())
				message = "flaps its wings ANGRILY!"
				m_type = 2

		if("twitch")
			message = "twitches violently."
			m_type = 1

		if("twitch_s","twitches")
			message = "twitches."
			m_type = 1

		if("nod","nods")
			message = "nods."
			m_type = 1

		if("deathgasp")
			message = "shudders violently for a moment, then becomes motionless, its eyes slowly darkening."
			m_type = 1

		if("glare","glares")
			var/M = null
			if(param)
				for(var/mob/A in view(null, null))
					if(param == A.name)
						M = A
						break
			if(!M)
				param = null

			if(param)
				message = "glares at [param]."
			else
				message = "glares."

		if("stare","stares")
			var/M = null
			if(param)
				for(var/mob/A in view(null, null))
					if(param == A.name)
						M = A
						break
			if(!M)
				param = null

			if(param)
				message = "stares at [param]."
			else
				message = "stares."

		if("look","looks")
			var/M = null
			if(param)
				for(var/mob/A in view(null, null))
					if(param == A.name)
						M = A
						break

			if(!M)
				param = null

			if(param)
				message = "looks at [param]."
			else
				message = "looks."
			m_type = 1


		if("law")
			if(istype(module,/obj/item/robot_module/security))
				message = "shows its legal authorization barcode."

				playsound(src.loc, 'sound/voice/biamthelaw.ogg', 50, 0)
				m_type = 2
			else
				to_chat(src, "You are not THE LAW, pal.")

		if("halt")
			if(istype(module,/obj/item/robot_module/security))
				message = "'s speakers skreech, \"Halt! Security!\"."

				playsound(src.loc, 'sound/voice/halt.ogg', 50, 0)
				m_type = 2
			else
				to_chat(src, "You are not security.")

		if("flip","flips")
			m_type = 1
			src.SpinAnimation(5,1)

			if (src.inventory_head)
				src.drop_hat()
				message = "кувырком опрокинул шляпу!"
			else
				message = "does a flip!"

		if("help")
			to_chat(src, "salute, bow-(none)/mob, clap, flap, aflap, twitch, twitches, nod, deathgasp, glare-(none)/mob, stare-(none)/mob, look,\n law, halt")

	..()

/mob/living/silicon/robot/verb/powerwarn()
	set category = "Robot Commands"
	set name = "Power Warning"

	if(handle_emote_CD(50))
		return

	if(!is_component_functioning("power cell") || !cell || !cell.charge)
		visible_message("The power warning light on <span class='name'>[src]</span> flashes urgently.",\
						 "You announce you are operating in low power mode.")
		playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)
	else
		to_chat(src, "<span class='warning'>You can only use this emote when you're out of charge.</span>")
