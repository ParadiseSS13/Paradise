/obj/machinery/computer/robotics
	name = "robotics control console"
	desc = "Used to remotely lockdown or detonate linked Cyborgs."
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "tech_key"
	icon_screen = "robot"
	req_access = list(access_robotics)
	circuit = /obj/item/circuitboard/robotics
	var/temp = null

	light_color = LIGHT_COLOR_PURPLE

	var/safety = 1

/obj/machinery/computer/robotics/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/robotics/attack_hand(var/mob/user as mob)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	ui_interact(user)

/obj/machinery/computer/robotics/proc/is_authenticated(var/mob/user as mob)
	if(user.can_admin_interact())
		return 1
	else if(allowed(user))
		return 1
	return 0

/obj/machinery/computer/robotics/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "robot_control.tmpl", "Robotic Control Console", 400, 500)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/robotics/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	var/list/robots = get_cyborgs(user)
	if(robots.len)
		data["robots"] = robots
	data["safety"] = safety
	// Also applies for cyborgs. Hides the manual self-destruct button.
	data["is_ai"] = issilicon(user)
	data["allowed"] = is_authenticated(user)
	return data

/obj/machinery/computer/robotics/Topic(href, href_list)
	if(..())
		return 1

	var/mob/user = usr
	if(!is_authenticated(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return

	// Destroys the cyborg
	if(href_list["detonate"])
		var/mob/living/silicon/robot/target = get_cyborg_by_name(href_list["detonate"])
		if(!target || !istype(target))
			return
		if(isAI(user) && (target.connected_ai != user))
			to_chat(user, "<span class='warning'>Access Denied. This robot is not linked to you.</span>")
			return
		// Cyborgs may blow up themselves via the console
		if((isrobot(user) && user != target) || !is_authenticated(user))
			to_chat(user, "<span class='warning'>Access Denied.</span>")
			return
		var/choice = input("Really detonate [target.name]?") in list ("Yes", "No")
		if(choice != "Yes")
			return
		if(!target || !istype(target))
			return

		// Antagonistic cyborgs? Left here for downstream
		if(target.mind && target.mind.special_role && target.emagged)
			to_chat(target, "Extreme danger.  Termination codes detected.  Scrambling security codes and automatic AI unlink triggered.")
			target.ResetSecurityCodes()
		else
			message_admins("<span class='notice'>[key_name_admin(usr)] detonated [key_name_admin(target)] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[target.x];Y=[target.y];Z=[target.z]'>JMP</a>)!</span>")
			log_game("\<span class='notice'>[key_name(usr)] detonated [key_name(target)]!</span>")
			to_chat(target, "<span class='danger'>Self-destruct command received.</span>")
			if(target.connected_ai)
				to_chat(target.connected_ai, "<br><br><span class='alert'>ALERT - Cyborg detonation detected: [target.name]</span><br>")
			spawn(10)
				target.self_destruct()

	// Locks or unlocks the cyborg
	else if(href_list["lockdown"])
		var/mob/living/silicon/robot/target = get_cyborg_by_name(href_list["lockdown"])
		if(!target || !istype(target))
			return

		if(isAI(user) && (target.connected_ai != user))
			to_chat(user, "<span class='warning'>Access Denied. This robot is not linked to you.</span>")
			return

		if(isrobot(user))
			to_chat(user, "<span class='warning'>Access Denied.</span>")
			return

		var/choice = input("Really [target.lockcharge ? "unlock" : "lockdown"] [target.name] ?") in list ("Yes", "No")
		if(choice != "Yes")
			return

		if(!target || !istype(target))
			return

		message_admins("<span class='notice'>[key_name_admin(usr)] [target.canmove ? "locked down" : "released"] [key_name_admin(target)]!</span>")
		log_game("[key_name(usr)] [target.canmove ? "locked down" : "released"] [key_name(target)]!")
		target.SetLockdown(!target.lockcharge)
		to_chat(target, "[!target.lockcharge ? "<span class='notice'>Your lockdown has been lifted!</span>" : "<span class='alert'>You have been locked down!</span>"]")
		if(target.connected_ai)
			to_chat(target.connected_ai, "[!target.lockcharge ? "<span class='notice'>NOTICE - Cyborg lockdown lifted</span>" : "<span class='alert'>ALERT - Cyborg lockdown detected</span>"]: <a href='?src=[target.connected_ai.UID()];track=[html_encode(target.name)]'>[target.name]</a></span><br>")

	// Remotely hacks the cyborg. Only antag AIs can do this and only to linked cyborgs.
	else if(href_list["hack"])
		var/mob/living/silicon/robot/target = get_cyborg_by_name(href_list["hack"])
		if(!target || !istype(target))
			return

		// Antag AI checks
		if(!istype(user, /mob/living/silicon/ai) || !(user.mind.special_role && user.mind.original == user))
			to_chat(user, "<span class='warning'>Access Denied.</span>")
			return

		if(target.connected_ai != user)
			to_chat(user, "<span class='warning'>Access Denied. This robot is not linked to you.</span>")
			return

		if(target.emagged)
			to_chat(user, "<span class='warning'>Robot is already hacked.</span>")
			return

		var/choice = input("Really hack [target.name]? This cannot be undone.") in list("Yes", "No")
		if(choice != "Yes")
			return

		if(!target || !istype(target))
			return

		message_admins("<span class='notice'>[key_name_admin(usr)] emagged [key_name_admin(target)] using robotic console!</span>")
		log_game("[key_name(usr)] emagged [key_name(target)] using robotic console!")
		target.emagged = 1
		to_chat(target, "<span class='notice'>Failsafe protocols overriden. New tools available.</span>")

	// Arms the emergency self-destruct system
	else if(href_list["arm"])
		if(istype(user, /mob/living/silicon))
			to_chat(user, "<span class='warning'>Access Denied.</span>")
			return

		safety = !safety
		to_chat(user, "<span class='notice'>You [safety ? "disarm" : "arm"] the emergency self destruct.</span>")

	// Destroys all accessible cyborgs if safety is disabled
	else if(href_list["nuke"])
		if(istype(user, /mob/living/silicon))
			to_chat(user, "Access Denied")
			return
		if(safety)
			to_chat(user, "Self-destruct aborted - safety active")
			return

		message_admins("<span class='notice'>[key_name_admin(usr)] detonated all cyborgs!</span>")
		log_game("\<span class='notice'>[key_name(usr)] detonated all cyborgs!</span>")

		for(var/mob/living/silicon/robot/R in GLOB.mob_list)
			if(istype(R, /mob/living/silicon/robot/drone))
				continue
			// Ignore antagonistic cyborgs
			if(R.scrambledcodes)
				continue
			to_chat(R, "<span class='danger'>Self-destruct command received.</span>")
			if(R.connected_ai)
				to_chat(R.connected_ai, "<br><br><span class='alert'>ALERT - Cyborg detonation detected: [R.name]</span><br>")
			spawn(10)
				R.self_destruct()

// Proc: get_cyborgs()
// Parameters: 1 (operator - mob which is operating the console.)
// Description: Returns NanoUI-friendly list of accessible cyborgs.
/obj/machinery/computer/robotics/proc/get_cyborgs(var/mob/operator)
	var/list/robots = list()

	for(var/mob/living/silicon/robot/R in GLOB.mob_list)
		// Ignore drones
		if(istype(R, /mob/living/silicon/robot/drone))
			continue
		// Ignore antagonistic cyborgs
		if(R.scrambledcodes)
			continue

		var/list/robot = list()
		robot["name"] = R.name
		if(R.stat)
			robot["status"] = "Not Responding"
		else if(!R.canmove)
			robot["status"] = "Lockdown"
		else
			robot["status"] = "Operational"

		if(R.cell)
			robot["cell"] = 1
			robot["cell_capacity"] = R.cell.maxcharge
			robot["cell_current"] = R.cell.charge
			robot["cell_percentage"] = round(R.cell.percent())
		else
			robot["cell"] = 0

		var/turf/pos = get_turf(R)
		var/area/bot_area = get_area(R)
		robot["xpos"] = pos.x
		robot["ypos"] = pos.y
		robot["zpos"] = pos.z
		robot["area"] = format_text(bot_area.name)

		robot["health"] = round(R.health * 100 / R.maxHealth,0.1)

		robot["module"] = R.module ? R.module.name : "None"
		robot["master_ai"] = R.connected_ai ? R.connected_ai.name : "None"
		robot["hackable"] = 0
		// Antag AIs know whether linked cyborgs are hacked or not.
		if(operator && istype(operator, /mob/living/silicon/ai) && (R.connected_ai == operator) && (operator.mind.special_role && operator.mind.original == operator))
			robot["hacked"] = R.emagged ? 1 : 0
			robot["hackable"] = R.emagged? 0 : 1
		robots.Add(list(robot))
	return robots

// Proc: get_cyborg_by_name()
// Parameters: 1 (name - Cyborg we are trying to find)
// Description: Helper proc for finding cyborg by name
/obj/machinery/computer/robotics/proc/get_cyborg_by_name(var/name)
	if(!name)
		return
	for(var/mob/living/silicon/robot/R in GLOB.mob_list)
		if(R.name == name)
			return R
