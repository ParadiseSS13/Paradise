/*
	Cyborg ClickOn()

	Cyborgs have no range restriction on attack_robot(), because it is basically an AI click.
	However, they do have a range restriction on item use, so they cannot do without the
	adjacency code.
*/

/mob/living/silicon/robot/ClickOn(var/atom/A, var/params)
	if(client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	if(next_click > world.time)
		return
	changeNext_click(1)


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
/mob/living/silicon/robot/proc/CtrlMiddleClickOn(var/atom/A)
	cycle_modules()
	return

//Middle click points
/mob/living/silicon/robot/MiddleClickOn(var/atom/A)
	if(istype(src, /mob/living/silicon/robot/drone))
		// Drones cannot point.
		return
	pointed(A)
	return

//Give cyborgs hotkey clicks without breaking existing uses of hotkey clicks
// for non-doors/apcs
/mob/living/silicon/robot/CtrlShiftClickOn(var/atom/A)
	A.BorgCtrlShiftClick(src)
/mob/living/silicon/robot/AltShiftClickOn(var/atom/A)
	A.BorgAltShiftClick(src)
/mob/living/silicon/robot/ShiftClickOn(var/atom/A)
	A.BorgShiftClick(src)
/mob/living/silicon/robot/CtrlClickOn(var/atom/A)
	A.BorgCtrlClick(src)
/mob/living/silicon/robot/AltClickOn(var/atom/A)
	A.BorgAltClick(src)

/atom/proc/BorgCtrlShiftClick(var/mob/user) // Examines
	if(user.client && user.client.eye == user)
		user.examinate(src)
	return

/atom/proc/BorgAltShiftClick()
	return

/obj/machinery/door/airlock/BorgAltShiftClick()  // Enables emergency override on doors! Forwards to AI code.
	AIAltShiftClick()

/atom/proc/BorgShiftClick(var/mob/user)
	if(user.client && user.client.eye == user)
		user.examinate(src)
	return

/obj/machinery/door/airlock/BorgShiftClick()  // Opens and closes doors! Forwards to AI code.
	AIShiftClick()

/atom/proc/BorgCtrlClick(var/mob/living/silicon/robot/user) //forward to human click if not overriden
	CtrlClick(user)

/obj/machinery/door/airlock/BorgCtrlClick() // Bolts doors. Forwards to AI code.
	AICtrlClick()

/obj/machinery/power/apc/BorgCtrlClick() // turns off/on APCs. Forwards to AI code.
	AICtrlClick()

/obj/machinery/turretid/BorgCtrlClick() //turret control on/off. Forwards to AI code.
	AICtrlClick()

/atom/proc/BorgAltClick(var/mob/living/silicon/robot/user)
	AltClick(user)
	return

/obj/machinery/door/airlock/BorgAltClick() // Eletrifies doors. Forwards to AI code.
	AIAltClick()

/obj/machinery/turretid/BorgAltClick() //turret lethal on/off. Forwards to AI code.
	AIAltClick()

/obj/machinery/ai_slipper/BorgCtrlClick() //Turns liquid dispenser on or off
	ToggleOn()

/obj/machinery/ai_slipper/BorgAltClick() //Dispenses liquid if on
	Activate()

/*
	As with AI, these are not used in click code,
	because the code for robots is specific, not generic.

	If you would like to add advanced features to robot
	clicks, you can do so here, but you will have to
	change attack_robot() above to the proper function
*/
/mob/living/silicon/robot/UnarmedAttack(atom/A)
	A.attack_robot(src)
/mob/living/silicon/robot/RangedAttack(atom/A)
	A.attack_robot(src)

/atom/proc/attack_robot(mob/user as mob)
	attack_ai(user)
	return
