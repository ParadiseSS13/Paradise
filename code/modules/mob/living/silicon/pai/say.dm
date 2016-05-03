/mob/living/silicon/pai/say(var/msg)
	if(silence_time)
		to_chat(src, "<font color=green>Communication circuits remain uninitialized.</font>")
	else
		..(msg)

/mob/living/silicon/pai/get_whisper_loc()
	if(loc == card)			// currently in its card?
		if(istype(card.loc, /mob/living))
			return card.loc	// allow a pai being held or in pocket to whisper
		else
			return card		// allow a pai in its card to whisper
	return ..()