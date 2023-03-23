/*
	PAI ClickOn()

	The PAI syndicate has the ability to interact with airlocks, etc. using its module. Mainly AI_interact is used.
*/

/mob/living/silicon/pai/ClickOn(atom/A, params)
	if(client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	if(next_click > world.time)
		return
	changeNext_click(1)

	if(is_ventcrawling(src)) // To stop interacting with anything while ventcrawling
		return
	if(stat == DEAD)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["shift"] && modifiers["alt"])
		AltShiftClickOn(A)
		return
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(incapacitated(ignore_restraints = TRUE, ignore_grab = TRUE, ignore_lying = TRUE))
		return

	if(next_move >= world.time)
		return

	face_atom(A) // change direction to face what you clicked on
	return

//Give cyborgs hotkey clicks without breaking existing uses of hotkey clicks
// for non-doors/apcs
/mob/living/silicon/pai/ShiftClickOn(atom/A)
	if(!ai_capability)
		return ..()
	if(!capa_is_cooldown)
		capa_is_cooldown = TRUE
		A.PAIShiftClick(src)
		addtimer(CALLBACK(src, .proc/reset_cooldown), ai_capability_cooldown)
		return
	return ..()


/mob/living/silicon/pai/CtrlClickOn(atom/A)
	if(!ai_capability)
		return ..()
	if(!capa_is_cooldown)
		capa_is_cooldown = TRUE
		A.PAICtrlClick(src)
		addtimer(CALLBACK(src, .proc/reset_cooldown), ai_capability_cooldown)
		return
	return ..()

/mob/living/silicon/pai/AltClickOn(atom/A)
	if(!ai_capability)
		return ..()
	if(!capa_is_cooldown)
		capa_is_cooldown = TRUE
		A.PAIAltClick(src)
		addtimer(CALLBACK(src, .proc/reset_cooldown), ai_capability_cooldown)
		return
	return ..()

/mob/living/silicon/pai/CtrlShiftClickOn(atom/A)
	if(!ai_capability)
		return ..()
	if(!capa_is_cooldown)
		capa_is_cooldown = TRUE
		A.PAICtrlShiftClick(src)
		addtimer(CALLBACK(src, .proc/reset_cooldown), ai_capability_cooldown)
		return
	return ..()

/mob/living/silicon/pai/AltShiftClickOn(atom/A)
	if(!ai_capability)
		return ..()
	if(!capa_is_cooldown)
		capa_is_cooldown = TRUE
		A.PAIAltShiftClick(src)
		addtimer(CALLBACK(src, .proc/reset_cooldown), ai_capability_cooldown)
		return
	return ..()


/atom/proc/PAIShiftClick(mob/user)
	if(user.client && user.client.eye == user)
		user.examinate(src)
	return

/atom/proc/PAICtrlClick(mob/living/silicon/robot/user) //forward to human click if not overriden
	CtrlClick(user)

/atom/proc/PAIAltClick(mob/living/silicon/robot/user)
	AltClick(user)
	return

/atom/proc/PAICtrlShiftClick(mob/user) // Examines
	if(user.client && user.client.eye == user)
		user.examinate(src)
	return

/atom/proc/PAIAltShiftClick()
	return


// AIRLOCKS

/obj/machinery/door/airlock/PAIShiftClick(mob/living/silicon/pai/user)  // Opens and closes doors! Forwards to AI code.
	AIShiftClick(user)

/obj/machinery/door/airlock/PAICtrlClick(mob/living/silicon/pai/user) // Bolts doors. Forwards to AI code.
	AICtrlClick(user)

/obj/machinery/door/airlock/PAIAltClick(mob/living/silicon/pai/user) // Eletrifies doors. Forwards to AI code.
	AIAltClick(user)

/obj/machinery/door/airlock/PAIAltShiftClick(mob/living/silicon/pai/user)  // Enables emergency override on doors! Forwards to AI code.
	AIAltShiftClick(user)


// APC

/obj/machinery/power/apc/PAICtrlClick(mob/living/silicon/pai/user) // turns off/on APCs. Forwards to AI code.
	AICtrlClick(user)


// AI SLIPPER

/obj/machinery/ai_slipper/PAICtrlClick(mob/living/silicon/pai/user) //Turns liquid dispenser on or off
	ToggleOn()

/obj/machinery/ai_slipper/PAIAltClick(mob/living/silicon/pai/user) //Dispenses liquid if on
	Activate()


// TURRETCONTROL

/obj/machinery/turretid/PAICtrlClick(mob/living/silicon/pai/user) //turret control on/off. Forwards to AI code.
	AICtrlClick(user)

/obj/machinery/turretid/PAIAltClick(mob/living/silicon/pai/user) //turret lethal on/off. Forwards to AI code.
	AIAltClick(user)

/mob/living/silicon/pai/proc/reset_cooldown()
	capa_is_cooldown = FALSE
	to_chat(src, "<span class = 'notice'>Your ability to interact with airlocks has been restored.</span>")
