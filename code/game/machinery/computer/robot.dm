/obj/machinery/computer/robotics
	name = "robotics control console"
	desc = "Used to remotely lockdown or detonate linked Cyborgs."
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "tech_key"
	icon_screen = "robot"
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/robotics
	var/temp = null

	light_color = LIGHT_COLOR_PURPLE

	var/safety = 1

/obj/machinery/computer/robotics/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/robotics/attack_hand(mob/user as mob)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	ui_interact(user)

/obj/machinery/computer/robotics/proc/is_authenticated(mob/user)
	if(!istype(user))
		return FALSE
	if(user.can_admin_interact())
		return TRUE
	if(allowed(user))
		return TRUE
	return FALSE

/**
  * Does this borg show up in the console
  *
  * Returns TRUE if a robot will show up in the console
  * Returns FALSE if a robot will not show up in the console
  * Arguments:
  * * R - The [mob/living/silicon/robot] to be checked
  */
/obj/machinery/computer/robotics/proc/console_shows(mob/living/silicon/robot/R)
	if(!istype(R))
		return FALSE
	if(istype(R, /mob/living/silicon/robot/drone))
		return FALSE
	if(R.scrambledcodes)
		return FALSE
	if(!atoms_share_level(get_turf(src), get_turf(R)))
		return FALSE
	return TRUE

/**
  * Check if a user can send a lockdown/detonate command to a specific borg
  *
  * Returns TRUE if a user can send the command (does not guarantee it will work)
  * Returns FALSE if a user cannot
  * Arguments:
  * * user - The [mob/user] to be checked
  * * R - The [mob/living/silicon/robot] to be checked
  * * telluserwhy - Bool of whether the user should be sent a to_chat message if they don't have access
  */
/obj/machinery/computer/robotics/proc/can_control(mob/user, mob/living/silicon/robot/R, telluserwhy = FALSE)
	if(!istype(user))
		return FALSE
	if(!console_shows(R))
		return FALSE
	if(isAI(user))
		if(R.connected_ai != user)
			if(telluserwhy)
				to_chat(user, span_warning("AIs can only control cyborgs which are linked to them."))
			return FALSE
	if(isrobot(user))
		if(R != user)
			if(telluserwhy)
				to_chat(user, span_warning("Cyborgs cannot control other cyborgs."))
			return FALSE
	return TRUE

/**
  * Check if the user is the right kind of entity to be able to hack borgs
  *
  * Returns TRUE if a user is a traitor AI, or aghost
  * Returns FALSE otherwise
  * Arguments:
  * * user - The [mob/user] to be checked
  */
/obj/machinery/computer/robotics/proc/can_hack_any(mob/user)
	if(!istype(user))
		return FALSE
	if(user.can_admin_interact())
		return TRUE
	if(!isAI(user))
		return FALSE
	return (user.mind.special_role && user.mind.is_original_mob(user))

/**
  * Check if the user is allowed to hack a specific borg
  *
  * Returns TRUE if a user can hack the specific cyborg
  * Returns FALSE if a user cannot
  * Arguments:
  * * user - The [mob/user] to be checked
  * * R - The [mob/living/silicon/robot] to be checked
  */
/obj/machinery/computer/robotics/proc/can_hack(mob/user, mob/living/silicon/robot/R)
	if(!can_hack_any(user))
		return FALSE
	if(!istype(R))
		return FALSE
	if(R.emagged)
		return FALSE
	if(R.connected_ai != user)
		return FALSE
	return TRUE

/obj/machinery/computer/robotics/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "RoboticsControlConsole",  name, 500, 460, master_ui, state)
		ui.open()

/obj/machinery/computer/robotics/ui_data(mob/user)
	var/list/data = list()
	data["auth"] = is_authenticated(user)
	data["can_hack"] = can_hack_any(user)
	data["cyborgs"] = list()
	data["safety"] = safety
	for(var/mob/living/silicon/robot/R in GLOB.mob_list)
		if(!console_shows(R))
			continue
		var/area/A = get_area(R)
		var/turf/T = get_turf(R)
		var/list/cyborg_data = list(
			name = R.name,
			uid = R.UID(),
			locked_down = R.lockcharge,
			locstring = "[A.name] ([T.x], [T.y])",
			status = R.stat,
			health = round(R.health * 100 / R.maxHealth, 0.1),
			charge = R.cell ? round(R.cell.percent()) : null,
			cell_capacity = R.cell ? R.cell.maxcharge : null,
			module = R.module ? R.module.name : "No Module Detected",
			synchronization = R.connected_ai,
			is_hacked =  R.connected_ai && R.emagged,
			hackable = can_hack(user, R),
		)
		data["cyborgs"] += list(cyborg_data)
	data["show_detonate_all"] = (data["auth"] && length(data["cyborgs"]) > 0 && ishuman(user))
	return data

/obj/machinery/computer/robotics/ui_act(action, params)
	if(..())
		return
	. = FALSE
	if(!is_authenticated(usr))
		to_chat(usr, span_warning("Access denied."))
		return
	switch(action)
		if("arm") // Arms the emergency self-destruct system
			if(issilicon(usr))
				to_chat(usr, span_danger("Access Denied (silicon detected)"))
				return
			safety = !safety
			to_chat(usr, span_notice("You [safety ? "disarm" : "arm"] the emergency self destruct."))
			. = TRUE
		if("nuke") // Destroys all accessible cyborgs if safety is disabled
			if(issilicon(usr))
				to_chat(usr, span_danger("Access Denied (silicon detected)"))
				return
			if(safety)
				to_chat(usr, span_danger("Self-destruct aborted - safety active"))
				return
			message_admins(span_notice("[key_name_admin(usr)] detonated all cyborgs!"))
			log_game("[span_notice("[key_name(usr)] detonated all cyborgs!")]")
			for(var/mob/living/silicon/robot/R in GLOB.mob_list)
				if(istype(R, /mob/living/silicon/robot/drone))
					continue
				// Ignore antagonistic cyborgs
				if(R.scrambledcodes)
					continue
				to_chat(R, span_danger("Self-destruct command received."))
				if(R.connected_ai)
					to_chat(R.connected_ai, "<br><br>[span_alert("ALERT - Cyborg detonation detected: [R.name]")]<br>")
				R.self_destruct()
			. = TRUE
		if("killbot") // destroys one specific cyborg
			var/mob/living/silicon/robot/R = locateUID(params["uid"])
			if(!can_control(usr, R, TRUE))
				return
			if(R.mind && R.mind.special_role && R.emagged)
				to_chat(R, span_userdanger("Extreme danger!  Termination codes detected.  Scrambling security codes and automatic AI unlink triggered."))
				R.ResetSecurityCodes()
				. = TRUE
				return
			var/turf/T = get_turf(R)
			message_admins(span_notice("[key_name_admin(usr)] detonated [key_name_admin(R)] ([ADMIN_COORDJMP(T)])!"))
			log_game("[span_notice("[key_name(usr)] detonated [key_name(R)]!")]")
			to_chat(R, span_danger("Self-destruct command received."))
			if(R.connected_ai)
				to_chat(R.connected_ai, "<br><br>[span_alert("ALERT - Cyborg detonation detected: [R.name]")]<br>")
			R.self_destruct()
			. = TRUE
		if("stopbot") // lock or unlock the borg
			if(isrobot(usr))
				to_chat(usr, span_danger("Access Denied."))
				return
			var/mob/living/silicon/robot/R = locateUID(params["uid"])
			if(!can_control(usr, R, TRUE))
				return
			message_admins(span_notice("[ADMIN_LOOKUPFLW(usr)] [!R.lockcharge ? "locked down" : "released"] [ADMIN_LOOKUPFLW(R)]!"))
			log_game("[key_name(usr)] [!R.lockcharge ? "locked down" : "released"] [key_name(R)]!")
			R.SetLockdown(!R.lockcharge)
			to_chat(R, !R.lockcharge ? span_notice("Your lockdown has been lifted!") : span_alert("You have been locked down!"))
			if(R.connected_ai)
				to_chat(R.connected_ai, "[!R.lockcharge ? span_notice("NOTICE - Cyborg lockdown lifted") : span_alert("ALERT - Cyborg lockdown detected")]: <a href='?src=[R.connected_ai.UID()];track=[html_encode(R.name)]'>[R.name]</a></span><br>")
			. = TRUE
		if("hackbot") // AIs hacking/emagging a borg
			var/mob/living/silicon/robot/R = locateUID(params["uid"])
			if(!can_hack(usr, R))
				return
			var/choice = input("Really hack [R.name]? This cannot be undone.") in list("Yes", "No")
			if(choice != "Yes")
				return
			log_game("[key_name(usr)] emagged [key_name(R)] using robotic console!")
			message_admins(span_notice("[key_name_admin(usr)] emagged [key_name_admin(R)] using robotic console!"))
			R.emagged = TRUE
			R.module.rebuild_modules()
			to_chat(R, span_notice("Failsafe protocols overriden. New tools available."))
			. = TRUE
