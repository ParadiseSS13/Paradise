GLOBAL_LIST_EMPTY(ai_displays)


/obj/machinery/ai_status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "AI display"
	anchored = TRUE

	/// Current mode
	var/mode = AI_DISPLAY_MODE_BLANK

	/// Current emotion, used to calculate an icon state
	var/emotion = "Neutral"

/obj/machinery/ai_status_display/Initialize(mapload)
	. = ..()
	GLOB.ai_displays |= src

/obj/machinery/ai_status_display/Destroy()
	GLOB.ai_displays -= src
	return ..()

/obj/machinery/ai_status_display/attack_ai(mob/living/silicon/ai/user)
	if(is_ai(user))
		user.ai_statuschange()

/obj/machinery/ai_status_display/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	mode = AI_DISPLAY_MODE_BSOD
	update_icon()
	..(severity)

/obj/machinery/ai_status_display/power_change()
	if(!..())
		return
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(1, LIGHTING_MINIMUM_POWER)

/obj/machinery/ai_status_display/flicker()
	if(stat & (NOPOWER | BROKEN))
		return FALSE

	addtimer(CALLBACK(src, PROC_REF(un_spookify), mode), 2 SECONDS)
	mode = null
	update_icon(UPDATE_OVERLAYS)
	return TRUE

/obj/machinery/ai_status_display/proc/un_spookify(our_real_state)
	mode = our_real_state
	if(stat & (NOPOWER | BROKEN))
		return FALSE
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/ai_status_display/update_overlays()
	. = ..()

	var/new_display

	underlays.Cut()

	if(stat & NOPOWER)
		return

	switch(mode)
		// Blank
		if(AI_DISPLAY_MODE_BLANK)
			new_display = "ai_off"

		// AI emoticon
		if(AI_DISPLAY_MODE_EMOTE)
			switch(emotion)
				if("Very Happy")
					new_display = "ai_veryhappy"
				if("Happy")
					new_display = "ai_happy"
				if("Neutral")
					new_display = "ai_neutral"
				if("Unsure")
					new_display = "ai_unsure"
				if("Confused")
					new_display = "ai_confused"
				if("Sad")
					new_display = "ai_sad"
				if("Surprised")
					new_display = "ai_surprised"
				if("Upset")
					new_display = "ai_upset"
				if("Angry")
					new_display = "ai_angry"
				if("BSOD")
					new_display = "ai_bsod"
				if("Blank")
					new_display = "ai_off"
				if("Problems?")
					new_display = "ai_trollface"
				if("Awesome")
					new_display = "ai_awesome"
				if("Dorfy")
					new_display = "ai_urist"
				if("Facepalm")
					new_display = "ai_facepalm"
				if("Friend Computer")
					new_display = "ai_friend"

		// BSOD
		if(AI_DISPLAY_MODE_BSOD)
			new_display = "ai_bsod"

	. += new_display
	underlays += emissive_appearance(icon, "lightmask")

/obj/machinery/ai_status_display/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0 SECONDS))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		deconstruct()

/obj/machinery/ai_status_display/on_deconstruction()
	. = ..()
	new /obj/item/mounted/frame/display/ai_display_frame(drop_location())
