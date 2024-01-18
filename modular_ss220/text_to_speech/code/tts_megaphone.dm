/obj/item/megaphone/say_msg(mob/living/user, message)
	. = ..()
	for(var/mob/M in get_mobs_in_view(14, src))
		var/effect = SOUND_EFFECT_MEGAPHONE
		if(isrobot(user))
			effect = SOUND_EFFECT_MEGAPHONE_ROBOT
		INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, user, M, message, user.tts_seed, FALSE, effect)
