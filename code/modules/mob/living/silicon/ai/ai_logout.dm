/mob/living/silicon/ai/Logout()
	..()
	for(var/obj/machinery/ai_status_display/O as anything in GLOB.ai_displays) //change status
		O.mode = AI_DISPLAY_MODE_BLANK

	view_core()
