/mob/living/silicon/ai/Logout()
	..()
	if(mind && mind.active && stat != DEAD)
		overlays += image('icons/effects/effects.dmi', icon_state = "zzz_glow_silicon")
	for(var/obj/machinery/ai_status_display/O as anything in GLOB.ai_displays) //change status
		O.mode = AI_DISPLAY_MODE_BLANK

	view_core()
