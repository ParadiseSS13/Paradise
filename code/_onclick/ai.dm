/*
	AI ClickOn()

	Note currently ai restrained() returns 0 in all cases,
	therefore restrained code has been removed

	The AI can double click to move the camera (this was already true but is cleaner),
	or double click a mob to track them.

	Note that AI have no need for the adjacency proc, and so this proc is a lot cleaner.
*/
/mob/living/silicon/ai/DblClickOn(var/atom/A, params)
	if(client.buildmode) // comes after object.Click to allow buildmode gui objects to be clicked
		build_click(src, client.buildmode, params, A)
		return

	if(control_disabled || stat) return
	next_move = world.time + 9

	if(ismob(A))
		ai_actual_track(A)
	else
		A.move_camera_by_click()


/mob/living/silicon/ai/ClickOn(var/atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(client.buildmode) // comes after object.Click to allow buildmode gui objects to be clicked
		build_click(src, client.buildmode, params, A)
		return

	if(control_disabled || stat)
		return

	if(alienAI)
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

	if(world.time <= next_move)
		return
	next_move = world.time + 9

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
		examine()
	return

/atom/proc/AIAltShiftClick()
	return

/obj/machinery/door/airlock/AIAltShiftClick()  // Sets/Unsets Emergency Access Override
	if(emagged)
		return
	if(!emergency)
		Topic("aiEnable=11", list("aiEnable"="11"), 1) // 1 meaning no window (consistency!)
	else
		Topic("aiDisable=11", list("aiDisable"="11"), 1)
	return

/atom/proc/AIShiftClick()
	return

/obj/machinery/door/airlock/AIShiftClick()  // Opens and closes doors!
	if(density)
		Topic("aiEnable=7", list("aiEnable"="7"), 1) // 1 meaning no window (consistency!)
	else
		Topic("aiDisable=7", list("aiDisable"="7"), 1)
	return

/atom/proc/AICtrlClick(var/mob/living/silicon/ai/user)
	if(user.holo)
		var/obj/machinery/hologram/holopad/H = user.holo
		H.face_atom(src)
	return

/obj/machinery/door/airlock/AICtrlClick() // Bolts doors
	if(locked)
		Topic("aiEnable=4", list("aiEnable"="4"), 1)// 1 meaning no window (consistency!)
	else
		Topic("aiDisable=4", list("aiDisable"="4"), 1)

/obj/machinery/power/apc/AICtrlClick() // turns off/on APCs.
	Topic("breaker=1", list("breaker"="1"), 0) // 0 meaning no window (consistency! wait...)

/obj/machinery/turretid/AICtrlClick() //turns off/on Turrets
	src.enabled = !src.enabled
	src.updateTurrets()

/atom/proc/AIAltClick(var/atom/A)
	AltClick(A)

/obj/machinery/door/airlock/AIAltClick() // Electrifies doors.
	if(emagged)
		return
	if(!secondsElectrified)
		// permanent shock
		Topic("aiEnable=6", list("aiEnable"="6"), 1) // 1 meaning no window (consistency!)
		use_log += text("\[[time_stamp()]\] <font color='red'>[usr.name] ([usr.ckey]) electrified [src].</font>")
	else
		// disable/6 is not in Topic; disable/5 disables both temporary and permanent shock
		Topic("aiDisable=5", list("aiDisable"="5"), 1)
		use_log += text("\[[time_stamp()]\] <font color='orange'>[usr.name] ([usr.ckey]) toggled turned off the [src]'s electrification.</font>")
	return

/obj/machinery/turretid/AIAltClick() //toggles lethal on turrets
	src.lethal = !src.lethal
	src.updateTurrets()

/atom/proc/AIMiddleClick()
	return

/obj/machinery/door/airlock/AIMiddleClick() // Toggles door bolt lights.
	if(!src.lights)
		Topic("aiEnable=10", list("aiEnable"="10"), 1) // 1 meaning no window (consistency!)
	else
		Topic("aiDisable=10", list("aiDisable"="10"), 1)
	return

//
// Override AdjacentQuick for AltClicking
//

/mob/living/silicon/ai/TurfAdjacent(var/turf/T)
	return (cameranet && cameranet.checkTurfVis(T))
