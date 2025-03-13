/*
	AI ClickOn()

	Note currently ai restrained() returns 0 in all cases,
	therefore restrained code has been removed

	The AI can double click to move the camera (this was already true but is cleaner),
	or double click a mob to track them.

	Note that AI have no need for the adjacency proc, and so this proc is a lot cleaner.
*/
/mob/living/silicon/ai/DblClickOn(atom/A, params)
	if(client.click_intercept)
		// Not doing a click intercept here, because otherwise we double-tap with the `ClickOn` proc.
		// But we return here since we don't want to do regular dblclick handling
		return

	if(control_disabled || stat)
		return
	if(ismecha(loc))
		return

	if(ismob(A))
		ai_actual_track(A, TRUE)
	else
		A.move_camera_by_click()


/mob/living/silicon/ai/ClickOn(atom/A, params)
	if(client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	if(next_click > world.time)
		return
	changeNext_click(1)

	if(control_disabled || stat)
		return

	if(!can_click_on_turf(A))
		return

	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["shift"] && modifiers["alt"])
		AltShiftClickOn(A)
		return
	if(modifiers["shift"] && modifiers["middle"])
		ShiftMiddleClickOn(A)
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
		waypoint_mode = FALSE
		return
	/*
		AI restrained() currently does nothing
	if(restrained())
		RestrainedClickOn(A)
	else
	*/
	A.add_hiddenprint(src)
	A.attack_ai(src)

/mob/living/silicon/ai/MiddleShiftControlClickOn(atom/A)
	return

/mob/living/silicon/ai/can_use_clickbinds()
	var/atom/atom_targeted = locateUID(client.moused_over)
	if(atom_targeted)
		return can_click_on_turf(atom_targeted)

/mob/living/silicon/ai/proc/can_click_on_turf(atom/A)
	var/turf/pixel_turf = isturf(A) ? A : get_turf_pixel(A)
	if(isnull(pixel_turf))
		return
	if(!can_see(A))
		if(isturf(A)) //On unmodified clients clicking the static overlay clicks the turf underneath
			return // So there's no point messaging admins
		add_attack_logs(src, src, "[key_name_admin(src)] might be running a modified client! (failed can_see on AI click of [A]([ADMIN_COORDJMP(pixel_turf)]))", ATKLOG_ALL)
		var/message = "[key_name(src)] might be running a modified client! (failed can_see on AI click of [A]([COORD(pixel_turf)]))"
		log_admin(message)
		GLOB.discord_manager.send2discord_simple_noadmins("**\[Warning]** [key_name(src)] might be running a modified client! (failed check_turf_vis on AI click of [A]([COORD(pixel_turf)]))")
		return FALSE

	var/turf_visible
	if(pixel_turf)
		turf_visible = GLOB.cameranet.check_turf_vis(pixel_turf)
		if(!turf_visible)
			if((istype(loc, /obj/item/aicard) || ismecha(loc)) && (pixel_turf in range(client.view, loc)))
				turf_visible = TRUE
			else
				if(pixel_turf.obscured)
					log_admin("[key_name_admin(src)] might be running a modified client! (failed check_turf_vis on AI click of [A]([COORD(pixel_turf)])")
					add_attack_logs(src, src, "[key_name_admin(src)] might be running a modified client! (failed check_turf_vis on AI click of [A]([ADMIN_COORDJMP(pixel_turf)]))", ATKLOG_ALL)
					GLOB.discord_manager.send2discord_simple_noadmins("**\[Warning]** [key_name(src)] might be running a modified client! (failed check_turf_vis on AI click of [A]([COORD(pixel_turf)]))")
				return FALSE
	return TRUE

/*
	AI has no need for the UnarmedAttack() and RangedAttack() procs,
	because the AI code is not generic;	attack_ai() is used instead.
	The below is only really for safety, or you can alter the way
	it functions and re-insert it above.
*/
/mob/living/silicon/ai/UnarmedAttack(atom/A)
	A.attack_ai(src)

/mob/living/silicon/ai/RangedAttack(atom/A, params)
	A.attack_ai(src)

/atom/proc/attack_ai(mob/user)
	return

/*
	Since the AI handles shift, ctrl, and alt-click differently
	than anything else in the game, atoms have separate procs
	for AI shift, ctrl, and alt clicking.
*/

/mob/living/silicon/ai/CtrlShiftClickOn(atom/A)
	A.AICtrlShiftClick(src)
/mob/living/silicon/ai/AltShiftClickOn(atom/A)
	A.AIAltShiftClick(src)
/mob/living/silicon/ai/ShiftMiddleClickOn(atom/A)
	A.AIShiftMiddleClick(src)
/mob/living/silicon/ai/ShiftClickOn(atom/A)
	A.AIShiftClick(src)
/mob/living/silicon/ai/CtrlClickOn(atom/A)
	A.AICtrlClick(src)
/mob/living/silicon/ai/AltClickOn(atom/A)
	A.AIAltClick(src)
/mob/living/silicon/ai/MiddleClickOn(atom/A)
	A.AIMiddleClick(src)


// DEFAULT PROCS TO OVERRIDE

/atom/proc/AICtrlShiftClick(mob/user)  // Examines
	if(user.client)
		user.examinate(src)
	return

/atom/proc/AIAltShiftClick()
	return

/atom/proc/AIShiftMiddleClick()
	return

/atom/proc/AIShiftClick(mob/living/user) // borgs use this too
	if(user.client)
		user.examinate(src)
	return

/atom/proc/AICtrlClick(mob/living/silicon/user)
	return

/atom/proc/AIAltClick(atom/A)
	AltClick(A)

/atom/proc/AIMiddleClick(mob/living/user)
	return

/mob/living/silicon/ai/TurfAdjacent(turf/T)
	return (GLOB.cameranet && GLOB.cameranet.check_turf_vis(T))


// APC

/obj/machinery/power/apc/AICtrlClick(mob/living/user) // turns off/on APCs.
	if(stat & BROKEN)
		return
	if(!user.can_remote_apc_interface(src))
		to_chat(user, "<span class='warning'>Unable to interface: Connection refused.</span>")
		return
	toggle_breaker(user)


// TURRETCONTROL

/obj/machinery/turretid/AICtrlClick(mob/living/silicon/user) //turns off/on Turrets
	enabled = !enabled
	updateTurrets()

/obj/machinery/turretid/AIAltClick() //toggles lethal on turrets
	if(lethal_is_configurable)
		lethal = !lethal
		updateTurrets()

// AIRLOCKS

/obj/machinery/door/airlock/AIAltShiftClick(mob/user)  // Sets/Unsets Emergency Access Override
	if(!ai_control_check(user))
		return
	toggle_emergency_status(user)

/obj/machinery/door/airlock/AIShiftClick(mob/user)  // Opens and closes doors!
	if(!ai_control_check(user))
		return
	open_close(user)

/obj/machinery/door/airlock/AICtrlClick(mob/living/silicon/user) // Bolts doors
	if(!ai_control_check(user))
		return
	if(ispulsedemon(user) || user.can_instant_lockdown() || do_after_once(user, 3 SECONDS, needhand = FALSE, target = src, allow_moving = TRUE, attempt_cancel_message = "Bolting [src] cancelled.", special_identifier = "Bolt", hidden = TRUE))
		toggle_bolt(user)


/obj/machinery/door/airlock/AIAltClick(mob/living/silicon/user) // Electrifies doors.
	if(!ai_control_check(user))
		return
	if(wires.is_cut(WIRE_ELECTRIFY))
		to_chat(user, "<span class='warning'>The electrification wire is cut - Cannot electrify the door.</span>")
	if(isElectrified())
		electrify(0, user, TRUE) // un-shock
	else
		if(ispulsedemon(user) || user.can_instant_lockdown() || do_after_once(user, 3 SECONDS, target = src, allow_moving = TRUE, attempt_cancel_message = "Shocking [src] cancelled.", special_identifier = "Shock", hidden = TRUE))
			electrify(-1, user, TRUE) // permanent shock + audio cue
			playsound(loc, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)


/obj/machinery/door/airlock/AIMiddleClick(mob/living/user) // Toggles door bolt lights.
	if(!ai_control_check(user))
		return
	toggle_light(user)

/obj/machinery/door/airlock/AIShiftMiddleClick(mob/user)  // Toggles door timings.
	if(!ai_control_check(user))
		return
	toggle_speed(user)
