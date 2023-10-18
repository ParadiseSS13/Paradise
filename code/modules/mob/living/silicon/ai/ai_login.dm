/mob/living/silicon/ai/Login()	//ThisIsDumb(TM) TODO: tidy this up �_� ~Carn
	..()

	if(stat != DEAD)
		for(var/obj/machinery/ai_status_display/O as anything in GLOB.ai_displays) //change status
			O.mode = AI_DISPLAY_MODE_EMOTE
			O.emotion = "Neutral"

	view_core()
