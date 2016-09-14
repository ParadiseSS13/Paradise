/*
	AI ClickOn()

	Note currently ai restrained() returns 0 in all cases,
	therefore restrained code has been removed

	The AI can double click to move the camera (this was already true but is cleaner),
	or double click a mob to track them.

	Note that AI have no need for the adjacency proc, and so this proc is a lot cleaner.
*/
/mob/living/silicon/ai/DblClickOn(var/atom/A, params)
	if(client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	if(control_disabled || stat) return

	if(ismob(A))
		ai_actual_track(A)
	else
		A.move_camera_by_click()


/mob/living/silicon/ai/ClickOn(var/atom/A, params)
	if(client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	if(world.time <= next_click)
		return
	next_click = world.time + 1


	if(control_disabled || stat)
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
		if(controlled_mech) //Are we piloting a mech? Placed here so the modifiers are not overridden.
			controlled_mech.click_action(A, src, params) //Override AI normal click behavior.
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

	if(world.time <= next_move)
		return

	if(aiCamera.in_camera_mode)
		aiCamera.camera_mode_off()
		aiCamera.captureimage(A, usr)
		return

	if(waypoint_mode)
		set_waypoint(A)
		waypoint_mode = 0
		return
	/*
		AI restrained() currently does nothing
	if(restrained())
		RestrainedClickOn(A)
	else
	*/
	A.add_hiddenprint(src)
	A.attack_ai(src)

/*
	AI has no need for the UnarmedAttack() and RangedAttack() procs,
	because the AI code is not generic;	attack_ai() is used instead.
	The below is only really for safety, or you can alter the way
	it functions and re-insert it above.
*/
/mob/living/silicon/ai/UnarmedAttack(atom/A)
	A.attack_ai(src)
/mob/living/silicon/ai/RangedAttack(atom/A)
	A.attack_ai(src)

/atom/proc/attack_ai(mob/user as mob)
	return

/*
	Since the AI handles shift, ctrl, and alt-click differently
	than anything else in the game, atoms have separate procs
	for AI shift, ctrl, and alt clicking.
*/

/mob/living/silicon/ai/CtrlShiftClickOn(var/atom/A)
	A.AICtrlShiftClick(src)
/mob/living/silicon/ai/AltShiftClickOn(var/atom/A)
	A.AIAltShiftClick(src)
/mob/living/silicon/ai/ShiftClickOn(var/atom/A)
	A.AIShiftClick(src)
/mob/living/silicon/ai/CtrlClickOn(var/atom/A)
	A.AICtrlClick(src)
/mob/living/silicon/ai/AltClickOn(var/atom/A)
	A.AIAltClick(src)
/mob/living/silicon/ai/MiddleClickOn(var/atom/A)
    A.AIMiddleClick(src)

/*
	The following criminally helpful code is just the previous code cleaned up;
	I have no idea why it was in atoms.dm instead of respective files.
*/

/atom/proc/AICtrlShiftClick(var/mob/user)  // Examines
	if(user.client)
		user.examinate(src)
	return

/atom/proc/AIAltShiftClick()
	return

/obj/machinery/door/airlock/AIAltShiftClick()  // Sets/Unsets Emergency Access Override
	if(density)
		Topic(src, list("src" = UID(), "command"="emergency", "activate" = "1"), 1) // 1 meaning no window (consistency!)
	else
		Topic(src, list("src" = UID(), "command"="emergency", "activate" = "0"), 1)
	return

/atom/proc/AIShiftClick(var/mob/user)
	if(user.client)
		user.examinate(src)
	return

/obj/machinery/door/airlock/AIShiftClick()  // Opens and closes doors!
	if(density)
		Topic(src, list("src" = UID(), "command"="open", "activate" = "1"), 1) // 1 meaning no window (consistency!)
	else
		Topic(src, list("src" = UID(), "command"="open", "activate" = "0"), 1)
	return

/atom/proc/AICtrlClick(var/mob/living/silicon/ai/user)
	if(user.holo)
		var/obj/machinery/hologram/holopad/H = user.holo
		H.face_atom(src)
	return

/obj/machinery/door/airlock/AICtrlClick() // Bolts doors
	if(locked)
		Topic(src, list("src" = UID(), "command"="bolts", "activate" = "0"), 1)// 1 meaning no window (consistency!)
	else
		Topic(src, list("src" = UID(), "command"="bolts", "activate" = "1"), 1)

/obj/machinery/power/apc/AICtrlClick() // turns off/on APCs.
	Topic("breaker=1", list("breaker"="1"), 0) // 0 meaning no window (consistency! wait...)

/obj/machinery/turretid/AICtrlClick() //turns off/on Turrets
	Topic(src, list("src" = UID(), "command"="enable", "value"="[!enabled]"), 1) // 1 meaning no window (consistency!)

/atom/proc/AIAltClick(var/atom/A)
	AltClick(A)

/obj/machinery/door/airlock/AIAltClick() // Electrifies doors.
	if(!electrified_until)
		// permanent shock
		Topic(src, list("src" = UID(), "command"="electrify_permanently", "activate" = "1"), 1) // 1 meaning no window (consistency!)
	else
		// disable/6 is not in Topic; disable/5 disables both temporary and permanent shock
		Topic(src, list("src" = UID(), "command"="electrify_permanently", "activate" = "0"), 1)
	return

/obj/machinery/turretid/AIAltClick() //toggles lethal on turrets
	Topic(src, list("src" = UID(), "command"="lethal", "value"="[!lethal]"), 1) // 1 meaning no window (consistency!)

/atom/proc/AIMiddleClick()
	return

/obj/machinery/door/airlock/AIMiddleClick() // Toggles door bolt lights.
	if(!src.lights)
		Topic(src, list("src" = UID(), "command"="lights", "activate" = "1"), 1) // 1 meaning no window (consistency!)
	else
		Topic(src, list("src" = UID(), "command"="lights", "activate" = "0"), 1)
	return


//
// Override AdjacentQuick for AltClicking
//

/mob/living/silicon/ai/TurfAdjacent(var/turf/T)
	return (cameranet && cameranet.checkTurfVis(T))
