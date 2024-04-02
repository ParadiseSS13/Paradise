/obj/item/megaphone/say_msg(mob/living/user, message)
	. = ..()
	for(var/mob/M in get_mobs_in_view(14, src))
		if(!M.client)
			continue
		user.cast_tts(M, message, user, FALSE, SOUND_EFFECT_MEGAPHONE)
