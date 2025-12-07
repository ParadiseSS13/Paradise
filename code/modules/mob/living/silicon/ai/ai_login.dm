/mob/living/silicon/ai/Login()	//ThisIsDumb(TM) TODO: tidy this up �_� ~Carn
	if(player_logged)
		overlays -= image('icons/effects/effects.dmi', icon_state = "zzz_glow_silicon")
	..()

	if(stat != DEAD)
		for(var/obj/machinery/ai_status_display/O as anything in GLOB.ai_displays) //change status
			O.mode = AI_DISPLAY_MODE_EMOTE
			O.emotion = "Neutral"

	view_core()
