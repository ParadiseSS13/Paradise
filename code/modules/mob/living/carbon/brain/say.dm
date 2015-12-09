//TODO: Convert this over for languages.
/mob/living/carbon/brain/say(var/message, var/datum/language/speaking = null)
	if (silent)
		return

	if(!(container && (istype(container, /obj/item/device/mmi) || istype(container, /obj/item/device/mmi/posibrain))))
		return //No MMI, can't speak, bucko./N
	else
		if(prob(emp_damage*4))
			if(prob(10))//10% chane to drop the message entirely
				return
			else
				message = Gibberish(message, (emp_damage*6))//scrambles the message, gets worse when emp_damage is higher

		..(message)

/mob/living/carbon/brain/can_speak(var/datum/language/speaking)
	if(speaking == all_languages["Robot Talk"] && (container && istype(container, /obj/item/device/mmi/posibrain))) //so posibrains can speak binary; less messy than adding the language
		return 1

	else return ..()

/mob/living/carbon/brain/binarycheck()
	return (container && istype(container, /obj/item/device/mmi/posibrain))

/mob/living/carbon/brain/handle_message_mode(var/message_mode, var/message, var/verb, var/speaking, var/used_radios, var/alt_name)
	switch(message_mode)
		if("headset")
			var/radio_worked = 0 // If any of the radios our brainmob could use functioned, this is set true so that we don't use any others
			// I'm doing it this way so that if the mecha radio fails for some reason, a radio MMI still has the built-in fallback
			if (container && istype(container,/obj/item/device/mmi))
				var/obj/item/device/mmi/c = container
				if (!radio_worked && c.mecha)
					var/obj/mecha/metalgear = c.mecha
					if(metalgear.radio)
						radio_worked = metalgear.radio.talk_into(src, message, message_mode, verb, speaking)

				else if(!radio_worked && istype(c, /obj/item/device/mmi/radio_enabled))
					var/obj/item/device/mmi/radio_enabled/R = c
					if(R.radio)
						radio_worked = R.radio.talk_into(src, message, message_mode, verb, speaking)
			return radio_worked
		if ("whisper")
			whisper_say(message, speaking, alt_name)
			return 1
		else return 0