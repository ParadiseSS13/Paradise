/obj/machinery/computer/emergency_shuttle
	name = "emergency shuttle console"
	desc = "For shuttle control."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	var/auth_need = 3
	var/list/authorized = list()

/obj/machinery/computer/emergency_shuttle/attackby(obj/item/weapon/card/W, mob/user, params)
	if(stat & (BROKEN|NOPOWER))
		return
	if(!istype(W, /obj/item/weapon/card))
		return
	if(shuttle_master.emergency.mode != SHUTTLE_DOCKED)
		return
	if(!user)
		return
	if(shuttle_master.emergency.timeLeft() < 11)
		return
	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(istype(W, /obj/item/device/pda))
			var/obj/item/device/pda/pda = W
			W = pda.id
		if(!W:access) //no access
			to_chat(user, "The access level of [W:registered_name]\'s card is not high enough. ")
			return

		var/list/cardaccess = W:access
		if(!istype(cardaccess, /list) || !cardaccess.len) //no access
			to_chat(user, "The access level of [W:registered_name]\'s card is not high enough. ")
			return

		if(!(access_heads in W:access)) //doesn't have this access
			to_chat(user, "The access level of [W:registered_name]\'s card is not high enough. ")
			return 0

		var/choice = alert(user, text("Would you like to (un)authorize a shortened launch time? [] authorization\s are still needed. Use abort to cancel all authorizations.", src.auth_need - src.authorized.len), "Shuttle Launch", "Authorize", "Repeal", "Abort")
		if(shuttle_master.emergency.mode != SHUTTLE_DOCKED || user.get_active_hand() != W)
			return 0

		var/seconds = shuttle_master.emergency.timeLeft()
		if(seconds <= 10)
			return 0

		switch(choice)
			if("Authorize")
				if(!authorized.Find(W:registered_name))
					authorized += W:registered_name
					if(auth_need - authorized.len > 0)
						message_admins("[key_name_admin(user)] has authorized early shuttle launch.")
						log_game("[key_name(user)] has authorized early shuttle launch in ([x], [y], [z]).")
						minor_announcement.Announce("[auth_need - authorized.len] more authorization(s) needed until shuttle is launched early")
					else
						message_admins("[key_name_admin(user)] has launched the emergency shuttle [seconds] seconds before launch.")
						log_game("[key_name(user)] has launched the emergency shuttle in ([x], [y], [z]) [seconds] seconds before launch.")
						minor_announcement.Announce("The emergency shuttle will launch in 10 seconds")
						shuttle_master.emergency.setTimer(100)

			if("Repeal")
				if(authorized.Remove(W:registered_name))
					minor_announcement.Announce("[auth_need - authorized.len] authorizations needed until shuttle is launched early")

			if("Abort")
				if(authorized.len)
					minor_announcement.Announce("All authorizations to launch the shuttle early have been revoked.")
					authorized.Cut()

/obj/machinery/computer/emergency_shuttle/emag_act(mob/user)
	if(!emagged && shuttle_master.emergency.mode == SHUTTLE_DOCKED)
		var/time = shuttle_master.emergency.timeLeft()
		message_admins("[key_name_admin(user)] has emagged the emergency shuttle: [time] seconds before launch.")
		log_game("[key_name(user)] has emagged the emergency shuttle in ([x], [y], [z]): [time] seconds before launch.")
		minor_announcement.Announce("The emergency shuttle will launch in 10 seconds", "SYSTEM ERROR:")
		shuttle_master.emergency.setTimer(100)
		emagged = 1


/obj/docking_port/mobile/emergency
	name = "emergency shuttle"
	id = "emergency"

	dwidth = 9
	width = 22
	height = 11
	dir = 4
	travelDir = 0
	roundstart_move = "emergency_away"
	var/sound_played = 0 //If the launch sound has been sent to all players on the shuttle itself

	var/datum/announcement/priority/emergency_shuttle_docked = new(0, new_sound = sound('sound/AI/shuttledock.ogg'))
	var/datum/announcement/priority/emergency_shuttle_called = new(0, new_sound = sound('sound/AI/shuttlecalled.ogg'))
	var/datum/announcement/priority/emergency_shuttle_recalled = new(0, new_sound = sound('sound/AI/shuttlerecalled.ogg'))

/obj/docking_port/mobile/emergency/register()
	if(!..())
		return 0 //shuttle master not initialized

	shuttle_master.emergency = src
	return 1

/obj/docking_port/mobile/emergency/timeLeft(divisor)
	if(divisor <= 0)
		divisor = 10
	if(!timer)
		return round(shuttle_master.emergencyCallTime/divisor, 1)

	var/dtime = world.time - timer
	switch(mode)
		if(SHUTTLE_ESCAPE)
			dtime = max(shuttle_master.emergencyEscapeTime - dtime, 0)
		if(SHUTTLE_DOCKED)
			dtime = max(shuttle_master.emergencyDockTime - dtime, 0)
		else

			dtime = max(shuttle_master.emergencyCallTime - dtime, 0)
	return round(dtime/divisor, 1)

/obj/docking_port/mobile/emergency/request(obj/docking_port/stationary/S, coefficient=1, area/signalOrigin, reason, redAlert)
	shuttle_master.emergencyCallTime = initial(shuttle_master.emergencyCallTime) * coefficient
	switch(mode)
		if(SHUTTLE_RECALL)
			mode = SHUTTLE_CALL
			timer = world.time - timeLeft(1)
		if(SHUTTLE_IDLE)
			mode = SHUTTLE_CALL
			timer = world.time
		if(SHUTTLE_CALL)
			if(world.time < timer)	//this is just failsafe
				timer = world.time
		else
			return

	if(prob(70))
		shuttle_master.emergencyLastCallLoc = signalOrigin
	else
		shuttle_master.emergencyLastCallLoc = null

	emergency_shuttle_called.Announce("The emergency shuttle has been called. [redAlert ? "Red Alert state confirmed: Dispatching priority shuttle. " : "" ]It will arrive in [timeLeft(600)] minutes.[reason][shuttle_master.emergencyLastCallLoc ? "\n\nCall signal traced. Results can be viewed on any communications console." : "" ]")

/obj/docking_port/mobile/emergency/cancel(area/signalOrigin)
	if(mode != SHUTTLE_CALL)
		return

	timer = world.time - timeLeft(1)
	mode = SHUTTLE_RECALL

	if(prob(70))
		shuttle_master.emergencyLastCallLoc = signalOrigin
	else
		shuttle_master.emergencyLastCallLoc = null
	emergency_shuttle_recalled.Announce("The emergency shuttle has been recalled.[shuttle_master.emergencyLastCallLoc ? " Recall signal traced. Results can be viewed on any communications console." : "" ]")

/*
/obj/docking_port/mobile/emergency/findTransitDock()
	. = shuttle_master.getDock("emergency_transit")
	if(.)	return .
	return ..()
*/


/obj/docking_port/mobile/emergency/check()
	if(!timer)
		return

	var/time_left = timeLeft(1)
	switch(mode)
		if(SHUTTLE_RECALL)
			if(time_left <= 0)
				mode = SHUTTLE_IDLE
				timer = 0
		if(SHUTTLE_CALL)
			if(time_left <= 0)
				//move emergency shuttle to station
				if(dock(shuttle_master.getDock("emergency_home")))
					setTimer(20)
					return
				mode = SHUTTLE_DOCKED
				timer = world.time
				send2irc("Server", "The Emergency Shuttle has docked with the station.")
				emergency_shuttle_docked.Announce("The Emergency Shuttle has docked with the station. You have [timeLeft(600)] minutes to board the Emergency Shuttle.")

/*
				//Gangs only have one attempt left if the shuttle has docked with the station to prevent suffering from dominator delays
				for(var/datum/gang/G in ticker.mode.gangs)
					if(isnum(G.dom_timer))
						G.dom_attempts = 0
					else
						G.dom_attempts = min(1,G.dom_attempts)
*/
		if(SHUTTLE_DOCKED)

			if(time_left <= 0 && shuttle_master.emergencyNoEscape)
				priority_announcement.Announce("Hostile environment detected. Departure has been postponed indefinitely pending conflict resolution.")
				sound_played = 0
				mode = SHUTTLE_STRANDED

			if(time_left <= 50 && !sound_played) //4 seconds left - should sync up with the launch
				sound_played = 1
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_begin.ogg'

			if(time_left <= 0 && !shuttle_master.emergencyNoEscape)
				//move each escape pod to its corresponding transit dock
				for(var/obj/docking_port/mobile/pod/M in shuttle_master.mobile)
					if(is_station_level(M.z)) //Will not launch from the mine/planet
						M.enterTransit()
				//now move the actual emergency shuttle to its transit dock
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_progress.ogg'
				enterTransit()
				mode = SHUTTLE_ESCAPE
				timer = world.time
				priority_announcement.Announce("The Emergency Shuttle has left the station. Estimate [timeLeft(600)] minutes until the shuttle docks at Central Command.")
		if(SHUTTLE_ESCAPE)
			if(time_left <= 0)
				//move each escape pod to its corresponding escape dock
				for(var/obj/docking_port/mobile/pod/M in shuttle_master.mobile)
					M.dock(shuttle_master.getDock("[M.id]_away"))
				//now move the actual emergency shuttle to centcomm
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_end.ogg'
				dock(shuttle_master.getDock("emergency_away"))
				mode = SHUTTLE_ENDGAME
				timer = 0
				open_dock()

/obj/docking_port/mobile/emergency/proc/open_dock();
/*
	for(var/obj/machinery/door/poddoor/shuttledock/D in airlocks)
		var/turf/T = get_step(D, D.checkdir)
		if(!istype(T,/turf/space))
			spawn(0)
				D.open()
*/ //Leaving this here incase someone decides to port -tg-'s escape shuttle stuff:
// This basically opens a big-ass row of blast doors when the shuttle arrives at centcom
/obj/docking_port/mobile/pod
	name = "escape pod"
	id = "pod"

	dwidth = 1
	width = 3
	height = 4

/obj/docking_port/mobile/pod/New()
	..()
	if(id == "pod")
		WARNING("[type] id has not been changed from the default. Use the id convention \"pod1\" \"pod2\" etc.")

/obj/docking_port/mobile/pod/cancel()
	return

/*
	findTransitDock()
		. = shuttle_master.getDock("[id]_transit")
		if(.)	return .
		return ..()
*/

/obj/machinery/computer/shuttle/pod
	name = "pod control computer"
	admin_controlled = 1
	shuttleId = "pod"
	possible_destinations = "pod_asteroid"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_available"
	density = 0

/obj/machinery/computer/shuttle/pod/update_icon()
	return

/obj/machinery/computer/shuttle/pod/emag_act(mob/user as mob)
	to_chat(user, "<span class='warning'> Access requirements overridden. The pod may now be launched manually at any time.</span>")
	admin_controlled = 0
	icon_state = "dorm_emag"

/obj/docking_port/stationary/random
	name = "escape pod"
	id = "pod"
	dwidth = 1
	width = 3
	height = 4
	var/target_area = /area/mine/dangerous/unexplored

/obj/docking_port/stationary/random/initialize()
	..()
	var/list/turfs = get_area_turfs(target_area)
	var/turf/T = pick(turfs)
	src.loc = T
