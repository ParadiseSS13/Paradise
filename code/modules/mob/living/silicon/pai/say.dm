/mob/living/silicon/pai/say(var/msg)
	if(silence_time)
		to_chat(src, "<font color=green>Communication circuits remain uninitialized.</font>")
	else
		..(msg)

/mob/living/silicon/pai/get_whisper_loc()
	if(loc == card)			// currently in its card?
		var/atom/movable/whisper_loc = card
		if(istype(card.loc, /obj/item/pda)) // Step up 1 level if in a PDA
			whisper_loc = card.loc
		if(istype(whisper_loc.loc, /mob/living))
			return whisper_loc.loc	// allow a pai being held or in pocket to whisper
		else
			return whisper_loc		// allow a pai in its card to whisper
	return ..()
