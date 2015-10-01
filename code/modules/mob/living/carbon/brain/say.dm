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

		if(istype(container, /obj/item/device/mmi/radio_enabled))
			var/radio_MMI_message = message //split off so the MMI can get a trimmed message without fucking up living/say()
			if(!speaking)
				speaking = parse_language(message)
			if(speaking)
				radio_MMI_message = copytext(message, 2 + length(speaking.key))
			else
				speaking = get_default_language()

			var/obj/item/device/mmi/radio_enabled/R = container
			if(R.radio)
				spawn(0) R.radio.hear_talk(src, trim(sanitize(radio_MMI_message)), say_quote(radio_MMI_message), speaking)

		..(message)

/mob/living/carbon/brain/can_speak(var/datum/language/speaking)
	if(speaking == all_languages["Robot Talk"] && istype(loc, /obj/item/device/mmi/posibrain)) //so posibrains can speak binary; less messy than adding the language
		return 1

	else return ..()

/mob/living/carbon/brain/binarycheck()
	return istype(loc, /obj/item/device/mmi/posibrain)