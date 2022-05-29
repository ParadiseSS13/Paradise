/*
	Cogscarab ClickOn()

	Due to cogscarab being a SUBTYPE of cyborgs, i've had to change it's basic mechanics such as manipulating doors and machinaries.
	They are clockwork not robot.
*/

/mob/living/silicon/robot/cogscarab/ClickOn(atom/A, params)
	if(client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	if(next_click > world.time)
		return
	changeNext_click(1)

	if(is_ventcrawling(src)) // To stop drones interacting with anything while ventcrawling
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

	var/obj/item/W = get_active_hand()

	if(!W && A.Adjacent(src))
		if(!ismachinery(A))
			A.attack_robot(src)
		else
			A.attack_hand(src)
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
			if(W)
				W.afterattack(A, src, 0, params)
			else
				RangedAttack(A, params)
	return


/mob/living/silicon/robot/cogscarab/ShiftClickOn(atom/A)
	A.ShiftClick(src)
	return

/mob/living/silicon/robot/cogscarab/CtrlClickOn(atom/A)
	A.CtrlClick(src)
	return

/mob/living/silicon/robot/cogscarab/AltClickOn(atom/A)
	A.AltClick(src)
	return

/mob/living/silicon/robot/cogscarab/CtrlShiftClickOn(atom/A)
	return

/mob/living/silicon/robot/cogscarab/AltShiftClickOn(atom/A)
	return

/mob/living/silicon/robot/cogscarab/RangedAttack(atom/A, params)
	return
