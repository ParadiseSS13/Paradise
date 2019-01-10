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
		// Not doing a click intercept here, because otherwise we double-tap with the `ClickOn` proc.
		// But we return here since we don't want to do regular dblclick handling
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

	if(next_click > world.time)
		return
	changeNext_click(1)

	if(multicam_on)
		var/turf/T = get_turf(A)
		if(T)
			for(var/obj/screen/movable/pic_in_pic/ai/P in T.vis_locs)
				if(P.ai == src)
					P.Click(params)
					break

	if(control_disabled || stat)
		return

	var/turf/pixel_turf = get_turf_pixel(A)
	if(isnull(pixel_turf))
		return
	if(!can_see(A))
		if(isturf(A)) //On unmodified clients clicking the static overlay clicks the turf underneath
			return // So there's no point messaging admins
		message_admins("[key_name_admin(src)] might be running a modified client! (failed can_see on AI click of [A]([ADMIN_COORDJMP(pixel_turf)]))")
		var/message = "[key_name(src)] might be running a modified client! (failed can_see on AI click of [A]([COORD(pixel_turf)]))"
		log_admin(message)
		send2irc_adminless_only("NOCHEAT", "[key_name(src)] might be running a modified client! (failed checkTurfVis on AI click of [A]([COORD(pixel_turf)]))")


	var/turf_visible
	if(pixel_turf)
		turf_visible = cameranet.checkTurfVis(pixel_turf)
		if(!turf_visible)
			if(istype(loc, /obj/item/aicard) && (pixel_turf in view(client.view, loc)))
				turf_visible = TRUE
			else
				if(pixel_turf.obscured)
					log_admin("[key_name_admin(src)] might be running a modified client! (failed checkTurfVis on AI click of [A]([COORD(pixel_turf)])")
					message_admins("[key_name_admin(src)] might be running a modified client! (failed checkTurfVis on AI click of [A]([ADMIN_COORDJMP(pixel_turf)]))")
					send2irc_adminless_only("NOCHEAT", "[key_name(src)] might be running a modified client! (failed checkTurfVis on AI click of [A]([COORD(pixel_turf)]))")
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

/obj/machinery/ai_slipper/AICtrlClick() //Turns liquid dispenser on or off
	ToggleOn()

/obj/machinery/ai_slipper/AIAltClick() //Dispenses liquid if on
	Activate()

//
// Override AdjacentQuick for AltClicking
//

/mob/living/silicon/ai/TurfAdjacent(var/turf/T)
	return (cameranet && cameranet.checkTurfVis(T))
