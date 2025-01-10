//TODO: Convert this over for languages.
/mob/living/brain/say(message, datum/language/speaking = null)
	if(stat == DEAD)
		return ..()
	if(!can_speak(warning = TRUE))
		return

	if(prob(emp_damage * 4))
		if(prob(10)) //10% chance to drop the message entirely
			return
		else
			message = brain_gibberish(message, (emp_damage*6))//scrambles the message, gets worse when emp_damage is higher

	..(message)

/mob/living/brain/whisper(message as text)
	if(!can_speak(warning = TRUE))
		return

	..()

/mob/living/brain/can_speak(warning = FALSE)
	. = ..()

	if(!istype(container, /obj/item/mmi))
		. = FALSE
	else if(istype(container, /obj/item/mmi/robotic_brain))
		var/obj/item/mmi/robotic_brain/R = container
		if(R && R.silenced)
			if(warning)
				to_chat(usr, "<span class='warning'>You cannot speak, as your internal speaker is turned off.</span>")
			. = FALSE

/mob/living/brain/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	switch(message_mode)
		if("headset")
			var/radio_worked = 0 // If any of the radios our brainmob could use functioned, this is set true so that we don't use any others
			// I'm doing it this way so that if the mecha radio fails for some reason, a radio MMI still has the built-in fallback
			if(container && istype(container,/obj/item/mmi))
				var/obj/item/mmi/c = container
				if(!radio_worked && c.mecha)
					var/obj/mecha/metalgear = c.mecha
					if(metalgear.radio)
						radio_worked = metalgear.radio.talk_into(src, message_pieces, message_mode, verb)

				else if(!radio_worked && c.radio)
					radio_worked = c.radio.talk_into(src, message_pieces, message_mode, verb)
			return radio_worked
		if("whisper")
			whisper_say(message_pieces)
			return 1
		else return 0
