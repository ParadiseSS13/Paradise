/*
	Cyborg ClickOn()

	Cyborgs have no range restriction on attack_robot(), because it is basically an AI click.
	However, they do have a range restriction on item use, so they cannot do without the
	adjacency code.
*/

/mob/living/silicon/robot/ClickOn(atom/A, params)
	if(client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	if(next_click > world.time)
		return
	changeNext_click(1)

	if(is_ventcrawling(src)) // To stop drones interacting with anything while ventcrawling
		return

	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["shift"] && modifiers["alt"])
		AltShiftClickOn(A)
		return
	if(modifiers["middle"] && modifiers["ctrl"])
		CtrlMiddleClickOn(A)
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

	if(incapacitated())
		return

	if(next_move >= world.time)
		return

	face_atom(A) // change direction to face what you clicked on

	if(aiCamera)
		if(aiCamera.in_camera_mode)
			aiCamera.camera_mode_off()
			if(is_component_functioning("camera"))
				aiCamera.captureimage(A, usr)
			else
				to_chat(src, "<span class='userdanger'>Your camera isn't functional.</span>")
			return

	/*
	cyborg restrained() currently does nothing
	if(restrained())
		RestrainedClickOn(A)
		return
	*/

	var/obj/item/W = get_active_hand()

	// Cyborgs have no range-checking unless there is item use
	if(!W)
		A.add_hiddenprint(src)
		A.attack_robot(src)
		return

	// buckled cannot prevent machine interlinking but stops arm movement
	if( buckled )
		return

	if(W == A)
		W.attack_self(src)
		return

	// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc in contents)
	if(A == loc || (A in loc) || (A in contents))
		W.melee_attack_chain(src, A, params)
		return

	if(!isturf(loc))
		return

	// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc && isturf(A.loc.loc))
	if(isturf(A) || isturf(A.loc))
		if(A.Adjacent(src)) // see adjacent.dm
			W.melee_attack_chain(src, A, params)
			return
		else
			W.afterattack(A, src, 0, params)
			return
	return

//Ctrl+Middle click cycles through modules
/mob/living/silicon/robot/proc/CtrlMiddleClickOn(atom/A)
	cycle_modules()
	return

//Middle click points
/mob/living/silicon/robot/MiddleClickOn(atom/A)
	if(istype(src, /mob/living/silicon/robot/drone))
		// Drones cannot point.
		return
	pointed(A)
	return

//Give cyborgs hotkey clicks without breaking existing uses of hotkey clicks
// for non-doors/apcs
/mob/living/silicon/robot/ShiftClickOn(atom/A)
	A.BorgShiftClick(src)
/mob/living/silicon/robot/CtrlClickOn(atom/A)
	A.BorgCtrlClick(src)
/mob/living/silicon/robot/AltClickOn(atom/A)
	A.BorgAltClick(src)
/mob/living/silicon/robot/CtrlShiftClickOn(atom/A)
	A.BorgCtrlShiftClick(src)
/mob/living/silicon/robot/AltShiftClickOn(atom/A)
	A.BorgAltShiftClick(src)


/atom/proc/BorgShiftClick(mob/user)
	if(user.client && user.client.eye == user)
		user.examinate(src)
	return

/atom/proc/BorgCtrlClick(mob/living/silicon/robot/user) //forward to human click if not overriden
	CtrlClick(user)

/atom/proc/BorgAltClick(mob/living/silicon/robot/user)
	AltClick(user)
	return

/atom/proc/BorgCtrlShiftClick(mob/user) // Examines
	if(user.client && user.client.eye == user)
		user.examinate(src)
	return

/atom/proc/BorgAltShiftClick()
	return


// AIRLOCKS

/obj/machinery/door/airlock/BorgShiftClick(mob/living/silicon/robot/user)  // Opens and closes doors! Forwards to AI code.
	AIShiftClick(user)

/obj/machinery/door/airlock/BorgCtrlClick(mob/living/silicon/robot/user) // Bolts doors. Forwards to AI code.
	AICtrlClick(user)

/obj/machinery/door/airlock/BorgAltClick(mob/living/silicon/robot/user) // Eletrifies doors. Forwards to AI code.
	AIAltClick(user)

/obj/machinery/door/airlock/BorgAltShiftClick(mob/living/silicon/robot/user)  // Enables emergency override on doors! Forwards to AI code.
	AIAltShiftClick(user)


// APC

/obj/machinery/power/apc/BorgCtrlClick(mob/living/silicon/robot/user) // turns off/on APCs. Forwards to AI code.
	AICtrlClick(user)


// AI SLIPPER

/obj/machinery/ai_slipper/BorgCtrlClick(mob/living/silicon/robot/user) //Turns liquid dispenser on or off
	ToggleOn()

/obj/machinery/ai_slipper/BorgAltClick(mob/living/silicon/robot/user) //Dispenses liquid if on
	Activate()


// TURRETCONTROL

/obj/machinery/turretid/BorgCtrlClick(mob/living/silicon/robot/user) //turret control on/off. Forwards to AI code.
	AICtrlClick(user)

/obj/machinery/turretid/BorgAltClick(mob/living/silicon/robot/user) //turret lethal on/off. Forwards to AI code.
	AIAltClick(user)

/*
	As with AI, these are not used in click code,
	because the code for robots is specific, not generic.

	If you would like to add advanced features to robot
	clicks, you can do so here, but you will have to
	change attack_robot() above to the proper function
*/
/mob/living/silicon/robot/UnarmedAttack(atom/A)
	A.attack_robot(src)

/mob/living/silicon/robot/RangedAttack(atom/A, params)
	A.attack_robot(src)

/atom/proc/attack_robot(mob/user)
	attack_ai(user)
	return
