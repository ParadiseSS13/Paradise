
/area/syndicate_depot
	name = "Suspicious Supply Depot"
	icon_state = "dark"
	tele_proof = 1

/area/syndicate_depot/core
	icon_state = "red"

	var/local_alarm = FALSE // Level 1: Local alarm tripped, bot spawned, red fire overlay activated
	var/called_backup = FALSE // Level 2: Remote alarm tripped. Bot may path through depot. Backup spawned.
	var/used_self_destruct = FALSE // Level 3: Self destruct activated. Depot will be destroyed shortly.

	var/run_started = FALSE
	var/run_finished = FALSE

	// Soft UID-based refs
	var/list/guard_list = list()
	var/list/hostile_list = list()
	var/list/dead_list = list()
	var/list/peaceful_list = list()
	var/list/shield_list = list()

	var/list/alert_log = list() // no refs, just a simple list of text strings

	var/used_lockdown = FALSE
	var/destroyed = FALSE
	var/something_looted = FALSE
	var/on_peaceful = FALSE
	var/peace_betrayed = FALSE
	var/detected_mech = FALSE
	var/detected_pod = FALSE
	var/detected_double_agent = FALSE
	var/mine_trigger_count = 0
	var/perimeter_shield_status = FALSE
	var/obj/machinery/computer/syndicate_depot/syndiecomms/comms_computer = null
	var/obj/structure/fusionreactor/reactor

/area/syndicate_depot/core/updateicon()
	if(destroyed)
		icon_state = null
		invisibility = INVISIBILITY_MAXIMUM
	else if(on_peaceful)
		icon_state = "green"
		invisibility = INVISIBILITY_LIGHTING
	else if(used_self_destruct)
		icon_state = "radiation"
		invisibility = INVISIBILITY_LIGHTING
	else if(called_backup)
		icon_state = "red"
		invisibility = INVISIBILITY_LIGHTING
	else if(local_alarm)
		icon_state = "bluenew"
		invisibility = INVISIBILITY_LIGHTING
	else
		icon_state = null
		invisibility = INVISIBILITY_MAXIMUM

/area/syndicate_depot/core/proc/reset_alert()

	if(used_self_destruct)
		for(var/obj/effect/overload/O in src)
			new /obj/structure/fusionreactor(O.loc)
			qdel(O)

	if(on_peaceful)
		peaceful_mode(FALSE, TRUE)

	local_alarm = FALSE
	called_backup = FALSE
	unlock_computers()
	used_self_destruct = FALSE

	run_started = FALSE
	run_finished = FALSE

	despawn_guards()
	hostile_list = list()
	dead_list = list()
	peaceful_list = list()

	something_looted = FALSE
	detected_mech = FALSE
	detected_pod = FALSE
	detected_double_agent = FALSE
	mine_trigger_count = 0
	updateicon()

	if(!istype(reactor))
		for(var/obj/structure/fusionreactor/R in src)
			reactor = R
			R.has_overloaded = FALSE

	for(var/obj/machinery/door/airlock/A in src)
		if(A.density && A.locked)
			spawn(0)
				A.unlock()

	alert_log += "Alert level reset."

/area/syndicate_depot/core/proc/increase_alert(reason)
	if(on_peaceful)
		peaceful_mode(FALSE, FALSE)
		peace_betrayed = TRUE
		activate_self_destruct("Depot has been infiltrated by double-agents.", TRUE, null)
		return
	if(!local_alarm)
		local_alarm(reason, FALSE)
		return
	if(!called_backup)
		call_backup(reason, FALSE)
		return
	if(!used_self_destruct)
		activate_self_destruct(reason, FALSE, null)
	updateicon()

/area/syndicate_depot/core/proc/locker_looted()
	if(!something_looted)
		something_looted = TRUE
		if(on_peaceful)
			increase_alert("Thieves!")
		if(perimeter_shield_status)
			increase_alert("Perimeter shield breach!")


/area/syndicate_depot/core/proc/armory_locker_looted()
	if(!run_finished && !used_self_destruct)
		if(shield_list.len)
			activate_self_destruct("Armory compromised despite armory shield being online.", FALSE)
			return
		declare_finished()

/area/syndicate_depot/core/proc/turret_died()
	something_looted = TRUE
	if(on_peaceful)
		increase_alert("Vandals!")

/area/syndicate_depot/core/proc/mine_triggered(mob/living/M)
	if(mine_trigger_count)
		return TRUE
	mine_trigger_count++
	increase_alert("Intruder detected by sentry mine: [M]")

/area/syndicate_depot/core/proc/saw_mech(obj/mecha/E)
	if(detected_mech)
		return
	detected_mech = TRUE
	increase_alert("Hostile mecha detected: [E]")

/area/syndicate_depot/core/proc/saw_pod(obj/spacepod/P)
	if(detected_pod)
		return
	detected_pod = TRUE
	if(!called_backup)
		increase_alert("Hostile spacepod detected: [P]")

/area/syndicate_depot/core/proc/saw_double_agent(mob/living/M)
	if(detected_double_agent)
		return
	detected_double_agent = TRUE
	increase_alert("Hostile double-agent detected: [M]")

/area/syndicate_depot/core/proc/peaceful_mode(newvalue, bycomputer)
	if(newvalue)
		log_game("Depot visit: started")
		alert_log += "Code GREEN: visitor mode started."
		ghostlog("The syndicate depot has visitors")
		for(var/mob/living/simple_animal/bot/medbot/syndicate/B in src)
			qdel(B)
		for(var/mob/living/simple_animal/hostile/syndicate/N in src)
			N.a_intent = INTENT_HELP
		for(var/obj/structure/closet/secure_closet/syndicate/depot/L in src)
			if(L.opened)
				L.close()
			if(!L.locked)
				L.locked = !L.locked
			L.req_access = list(ACCESS_SYNDICATE_LEADER)
			L.update_icon()
	else
		log_game("Depot visit: ended")
		alert_log += "Visitor mode ended."
		for(var/mob/living/simple_animal/hostile/syndicate/N in src)
			N.a_intent = INTENT_HARM
		for(var/obj/machinery/door/airlock/A in src)
			A.req_access_txt = "[ACCESS_SYNDICATE_LEADER]"
		for(var/obj/structure/closet/secure_closet/syndicate/depot/L in src)
			if(L.locked)
				L.locked = !L.locked
			L.req_access = list()
			L.update_icon()
	on_peaceful = newvalue
	if(newvalue)
		announce_here("Depot Visitor","A Syndicate agent is visiting the depot.")
	else
		if(bycomputer)
			message_admins("Syndicate Depot visitor mode deactivated. Visitors:")
			announce_here("Depot Alert","Visit ended. All visting agents signed out.")
		else
			message_admins("Syndicate Depot visitor mode auto-deactivated because visitors robbed depot! Visitors:")
			announce_here("Depot Alert","A visiting agent has betrayed the Syndicate. Shoot all visitors on sight!")
		for(var/mob/M in list_getmobs(peaceful_list))
			if("syndicate" in M.faction)
				M.faction -= "syndicate"
				message_admins("- SYNDI DEPOT VISITOR: [ADMIN_FULLMONTY(M)]")
				list_add(M, hostile_list)
		peaceful_list = list()
	updateicon()

/area/syndicate_depot/core/proc/local_alarm(reason, silent)
	if(local_alarm)
		return
	log_game("Depot code: blue: " + list_show(hostile_list, TRUE))
	ghostlog("The syndicate depot has declared code blue.")
	alert_log += "Code BLUE: [reason]"
	local_alarm = TRUE
	if(!silent)
		announce_here("Depot Code BLUE", reason)
		var/list/possible_bot_spawns = list()
		for(var/obj/effect/landmark/L in GLOB.landmarks_list)
			if(L.name == "syndi_depot_bot")
				possible_bot_spawns |= L
		if(possible_bot_spawns.len)
			var/obj/effect/landmark/S = pick(possible_bot_spawns)
			new /obj/effect/portal(get_turf(S))
			var/mob/living/simple_animal/bot/ed209/syndicate/B = new /mob/living/simple_animal/bot/ed209/syndicate(get_turf(S))
			list_add(B, guard_list)
			B.depotarea = src
	updateicon()

/area/syndicate_depot/core/proc/call_backup(reason, silent)
	if(called_backup || used_self_destruct)
		return
	log_game("Depot code: red: " + list_show(hostile_list, TRUE))
	ghostlog("The syndicate depot has declared code red.")
	alert_log += "Code RED: [reason]"
	called_backup = TRUE
	lockout_computers()
	for(var/obj/machinery/door/poddoor/P in GLOB.airlocks)
		if(P.density && P.id_tag == "syndi_depot_lvl2" && !P.operating)
			spawn(0)
				P.open()
	if(!silent)
		announce_here("Depot Code RED", reason)

	var/comms_online = FALSE
	if(istype(comms_computer))
		if(!(comms_computer.stat & (NOPOWER|BROKEN)))
			comms_online = TRUE
	if(comms_online)
		spawn(0)
			for(var/obj/effect/landmark/L in GLOB.landmarks_list)
				if(prob(50))
					if(L.name == "syndi_depot_backup")
						var/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/space/S = new /mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/space(get_turf(L))
						S.name = "Syndicate Backup " + "([rand(1, 1000)])"
						S.depotarea = src
						list_add(S, guard_list)
	else if(!silent)
		announce_here("Depot Communications Offline", "Comms computer is damaged, destroyed or depowered. Unable to call in backup from Syndicate HQ.")
	updateicon()

/area/syndicate_depot/core/proc/activate_self_destruct(reason, containment_failure, mob/user)
	if(used_self_destruct)
		return
	log_game("Depot code: delta: " + list_show(hostile_list, TRUE))
	ghostlog("The syndicate depot is about to self-destruct.")
	alert_log += "Code DELTA: [reason]"
	used_self_destruct = TRUE
	local_alarm = TRUE
	called_backup = TRUE
	activate_lockdown(TRUE)
	lockout_computers()
	updateicon()
	despawn_guards()
	if(containment_failure)
		announce_here("Depot Code DELTA", reason)
	else
		announce_here("Depot Code DELTA","[reason] Depot declared lost to hostile forces. Priming self-destruct!")

	if(user)
		var/turf/T = get_turf(user)
		var/area/A = get_area(T)
		var/log_msg = "[key_name(user)] has triggered the depot self destruct at [A.name] ([T.x],[T.y],[T.z])"
		message_admins(log_msg)
		log_game(log_msg)
		playsound(user, 'sound/machines/alarm.ogg', 100, 0, 0)
	else
		log_game("Depot self destruct activated.")
	if(reactor)
		if(!reactor.has_overloaded)
			reactor.overload(containment_failure)
	else
		log_debug("Depot: [src] called activate_self_destruct with no reactor.");
		message_admins("<span class='adminnotice'>Syndicate Depot lacks reactor to initiate self-destruct. Must be destroyed manually.</span>")
	updateicon()

/area/syndicate_depot/core/proc/activate_lockdown()
	if(used_lockdown)
		return
	used_lockdown = TRUE
	for(var/obj/machinery/door/airlock/A in src)
		spawn(0)
			A.close()
			if(A.density && !A.locked)
				A.lock()

/area/syndicate_depot/core/proc/lockout_computers()
	for(var/obj/machinery/computer/syndicate_depot/C in src)
		C.activate_security_lockout()

/area/syndicate_depot/core/proc/unlock_computers()
	for(var/obj/machinery/computer/syndicate_depot/C in src)
		C.security_lockout = FALSE

/area/syndicate_depot/core/proc/set_emergency_access(var/openaccess)
	for(var/obj/machinery/door/airlock/A in src)
		if(istype(A, /obj/machinery/door/airlock/hatch/syndicate/vault))
			continue
		A.emergency = !!openaccess
		A.update_icon()

/area/syndicate_depot/core/proc/toggle_falsewalls()
	for(var/obj/structure/falsewall/plastitanium/F in src)
		spawn(0)
			F.toggle()

/area/syndicate_depot/core/proc/toggle_teleport_beacon()
	for(var/obj/machinery/bluespace_beacon/syndicate/B in src)
		return B.toggle()

/area/syndicate_depot/core/proc/announce_here(a_header = "Depot Defense Alert", a_text = "")
	var/msg_text = "<font size=4 color='red'>[a_header]</font><br><font color='red'>[a_text]</font>"
	var/list/receivers = list()
	for(var/mob/M in GLOB.mob_list)
		if(!M.ckey)
			continue
		var/turf/T = get_turf(M)
		if(T && T.loc && T.loc == src)
			receivers |= M
	for(var/mob/R in receivers)
		to_chat(R, msg_text)
		R << sound('sound/misc/notice1.ogg')

/area/syndicate_depot/core/proc/shields_up()
	if(shield_list.len)
		return
	for(var/obj/effect/landmark/L in GLOB.landmarks_list)
		if(L.name == "syndi_depot_shield")
			var/obj/machinery/shieldwall/syndicate/S = new /obj/machinery/shieldwall/syndicate(L.loc)
			shield_list += S.UID()
	for(var/obj/structure/closet/secure_closet/syndicate/depot/armory/L in src)
		if(L.opened)
			L.close()
		if(!L.locked)
			L.locked = !L.locked
		L.update_icon()
	for(var/obj/machinery/door/airlock/hatch/syndicate/vault/A in src)
		A.lock()

/area/syndicate_depot/core/proc/shields_key_check()
	if(!shield_list.len)
		return
	if(detected_mech || detected_pod || detected_double_agent)
		return
	shields_down()

/area/syndicate_depot/core/proc/shields_down()
	for(var/shuid in shield_list)
		var/obj/machinery/shieldwall/syndicate/S = locateUID(shuid)
		if(S)
			qdel(S)
	shield_list = list()
	for(var/obj/structure/closet/secure_closet/syndicate/depot/armory/L in src)
		if(L.locked)
			L.locked = !L.locked
			L.update_icon()
	for(var/obj/machinery/door/airlock/hatch/syndicate/vault/A in src)
		A.unlock()

/area/syndicate_depot/core/proc/despawn_guards()
	for(var/mob/thismob in list_getmobs(guard_list))
		new /obj/effect/portal(get_turf(thismob))
		qdel(thismob)
	guard_list = list()

/area/syndicate_depot/core/proc/ghostlog(gmsg)
	if(istype(reactor))
		var/image/alert_overlay = image('icons/obj/flag.dmi', "syndiflag")
		notify_ghosts(gmsg, title = "Depot News", source = reactor.loc, alert_overlay = alert_overlay, action = NOTIFY_JUMP)

/area/syndicate_depot/core/proc/declare_started()
	if(!run_started)
		run_started = TRUE
		log_game("Depot run: started: " + list_show(hostile_list, TRUE))

/area/syndicate_depot/core/proc/declare_finished()
	if(!run_finished && !used_self_destruct)
		run_finished = TRUE
		log_game("Depot run: finished successfully: " + list_show(hostile_list, TRUE))

/area/syndicate_depot/core/proc/list_add(mob/M, list/L)
	if(!istype(M))
		return
	var/mob_uid = M.UID()
	if(mob_uid in L)
		return
	L += mob_uid

/area/syndicate_depot/core/proc/list_remove(mob/M, list/L)
	if(!istype(M))
		return
	var/mob_uid = M.UID()
	if(mob_uid in L)
		L -= mob_uid

/area/syndicate_depot/core/proc/list_includes(mob/M, list/L)
	if(!istype(M))
		return FALSE
	var/mob_uid = M.UID()
	if(mob_uid in L)
		return TRUE
	return FALSE

/area/syndicate_depot/core/proc/list_show(list/L, show_ckeys = FALSE)
	var/list/formatted = list()
	for(var/uid in L)
		var/mob/M = locateUID(uid)
		if(!istype(M))
			continue
		if(show_ckeys)
			formatted += "[M.ckey]([M])"
		else
			formatted += "[M]"
	return formatted.Join(", ")

/area/syndicate_depot/core/proc/list_getmobs(list/L, show_ckeys = FALSE)
	var/list/moblist = list()
	for(var/uid in L)
		var/mob/M = locateUID(uid)
		if(!istype(M))
			continue
		moblist += M
	return moblist

/area/syndicate_depot/core/proc/list_gethtmlmobs(list/L)
	var/returntext = ""
	var/list/moblist = list_getmobs(L)
	if(moblist.len)
		returntext += "<UL>"
		for(var/mob/thismob in moblist)
			returntext += "<LI>[thismob]</LI>"
		returntext += "</UL>"
	else
		returntext += "<BR>NONE"
	return returntext

/area/syndicate_depot/outer
	name = "Suspicious Asteroid"
	icon_state = "green"

/area/syndicate_depot/perimeter
	name = "Suspicious Asteroid Perimeter"
	icon_state = "yellow"
	var/list/shield_list = list()

/area/syndicate_depot/perimeter/proc/perimeter_shields_up()
	if(shield_list.len)
		return
	for(var/turf/T in src)
		var/obj/machinery/shieldwall/syndicate/S = new /obj/machinery/shieldwall/syndicate(T)
		S.alpha = 0
		shield_list += S.UID()

/area/syndicate_depot/perimeter/proc/perimeter_shields_down()
	for(var/shuid in shield_list)
		var/obj/machinery/shieldwall/syndicate/S = locateUID(shuid)
		if(S)
			qdel(S)
	shield_list = list()
