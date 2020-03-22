/obj/machinery/computer/emergency_shuttle
	name = "emergency shuttle console"
	desc = "For shuttle control."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	var/auth_need = 3
	var/list/authorized = list()

/obj/machinery/computer/emergency_shuttle/attackby(obj/item/card/W, mob/user, params)
	if(stat & (BROKEN|NOPOWER))
		return
	if(!istype(W, /obj/item/card))
		return
	if(SSshuttle.emergency.mode != SHUTTLE_DOCKED)
		return
	if(!user)
		return
	if(SSshuttle.emergency.timeLeft() < 11)
		return
	if(istype(W, /obj/item/card/id)||istype(W, /obj/item/pda))
		if(istype(W, /obj/item/pda))
			var/obj/item/pda/pda = W
			W = pda.id
		if(!W:access) //no access
			to_chat(user, "The access level of [W:registered_name]\'s card is not high enough. ")
			return

		var/list/cardaccess = W:access
		if(!istype(cardaccess, /list) || !cardaccess.len) //no access
			to_chat(user, "The access level of [W:registered_name]\'s card is not high enough. ")
			return

		if(!(ACCESS_HEADS in W:access)) //doesn't have this access
			to_chat(user, "The access level of [W:registered_name]\'s card is not high enough. ")
			return 0

		var/choice = alert(user, text("Would you like to (un)authorize a shortened launch time? [] authorization\s are still needed. Use abort to cancel all authorizations.", src.auth_need - src.authorized.len), "Shuttle Launch", "Authorize", "Repeal", "Abort")
		if(SSshuttle.emergency.mode != SHUTTLE_DOCKED || user.get_active_hand() != W)
			return 0

		var/seconds = SSshuttle.emergency.timeLeft()
		if(seconds <= 10)
			return 0

		switch(choice)
			if("Authorize")
				if(!authorized.Find(W:registered_name))
					authorized += W:registered_name
					if(auth_need - authorized.len > 0)
						message_admins("[key_name_admin(user)] has authorized early shuttle launch.")
						log_game("[key_name(user)] has authorized early shuttle launch in ([x], [y], [z]).")
						GLOB.minor_announcement.Announce("[auth_need - authorized.len] more authorization(s) needed until shuttle is launched early")
					else
						message_admins("[key_name_admin(user)] has launched the emergency shuttle [seconds] seconds before launch.")
						log_game("[key_name(user)] has launched the emergency shuttle in ([x], [y], [z]) [seconds] seconds before launch.")
						GLOB.minor_announcement.Announce("The emergency shuttle will launch in 10 seconds")
						SSshuttle.emergency.setTimer(100)

			if("Repeal")
				if(authorized.Remove(W:registered_name))
					GLOB.minor_announcement.Announce("[auth_need - authorized.len] authorizations needed until shuttle is launched early")

			if("Abort")
				if(authorized.len)
					GLOB.minor_announcement.Announce("All authorizations to launch the shuttle early have been revoked.")
					authorized.Cut()

/obj/machinery/computer/emergency_shuttle/emag_act(mob/user)
	if(!emagged && SSshuttle.emergency.mode == SHUTTLE_DOCKED)
		var/time = SSshuttle.emergency.timeLeft()
		message_admins("[key_name_admin(user)] has emagged the emergency shuttle: [time] seconds before launch.")
		log_game("[key_name(user)] has emagged the emergency shuttle in ([x], [y], [z]): [time] seconds before launch.")
		GLOB.minor_announcement.Announce("The emergency shuttle will launch in 10 seconds", "SYSTEM ERROR:")
		SSshuttle.emergency.setTimer(100)
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

	var/canRecall = TRUE //no bad condom, do not recall the crew transfer shuttle!


/obj/docking_port/mobile/emergency/register()
	if(!..())
		return 0 //shuttle master not initialized

	SSshuttle.emergency = src
	return 1

/obj/docking_port/mobile/emergency/Destroy(force)
	if(force)
		// This'll make the shuttle subsystem use the backup shuttle.
		if(SSshuttle.emergency == src)
			// If we're the selected emergency shuttle
			SSshuttle.emergencyDeregister()


	return ..()

/obj/docking_port/mobile/emergency/timeLeft(divisor)
	if(divisor <= 0)
		divisor = 10
	if(!timer)
		return round(SSshuttle.emergencyCallTime/divisor, 1)

	var/dtime = world.time - timer
	switch(mode)
		if(SHUTTLE_ESCAPE)
			dtime = max(SSshuttle.emergencyEscapeTime - dtime, 0)
		if(SHUTTLE_DOCKED)
			dtime = max(SSshuttle.emergencyDockTime - dtime, 0)
		else

			dtime = max(SSshuttle.emergencyCallTime - dtime, 0)
	return round(dtime/divisor, 1)

/obj/docking_port/mobile/emergency/request(obj/docking_port/stationary/S, coefficient=1, area/signalOrigin, reason, redAlert)
	SSshuttle.emergencyCallTime = initial(SSshuttle.emergencyCallTime) * coefficient
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
		SSshuttle.emergencyLastCallLoc = signalOrigin
	else
		SSshuttle.emergencyLastCallLoc = null

	emergency_shuttle_called.Announce("The emergency shuttle has been called. [redAlert ? "Red Alert state confirmed: Dispatching priority shuttle. " : "" ]It will arrive in [timeLeft(600)] minutes.[reason][SSshuttle.emergencyLastCallLoc ? "\n\nCall signal traced. Results can be viewed on any communications console." : "" ]")

	if(reason == "Automatic Crew Transfer" && signalOrigin == null) // Best way we have to check that it's actually a crew transfer and not just a player using the same message- any other calls to this proc should have a signalOrigin.
		GLOB.atc.shift_ending()
	else // Emergency shuttle call (probably)
		GLOB.atc.reroute_traffic(yes = TRUE)


/obj/docking_port/mobile/emergency/cancel(area/signalOrigin)
	if(!canRecall)
		return

	if(mode != SHUTTLE_CALL)
		return

	timer = world.time - timeLeft(1)
	mode = SHUTTLE_RECALL

	if(prob(70))
		SSshuttle.emergencyLastCallLoc = signalOrigin
	else
		SSshuttle.emergencyLastCallLoc = null
	emergency_shuttle_recalled.Announce("The emergency shuttle has been recalled.[SSshuttle.emergencyLastCallLoc ? " Recall signal traced. Results can be viewed on any communications console." : "" ]")

/obj/docking_port/mobile/emergency/proc/is_hijacked()
	for(var/mob/living/player in GLOB.player_list)
		if(!player.mind)
			continue
		if(player.stat == DEAD)  // Corpses
			continue
		if(iszombie(player))  // Walking corpses
			continue
		if(issilicon(player)) //Borgs are technically dead anyways
			continue
		if(isanimal(player)) //Poly does not own the shuttle
			continue
		if(ishuman(player)) //hostages allowed on the shuttle, check for restraints
			var/mob/living/carbon/human/H = player
			if(!H.check_death_method() && H.health <= HEALTH_THRESHOLD_DEAD) //new crit users who are in hard crit are considered dead
				continue
			if(H.handcuffed) //cuffs
				continue
			if(H.wear_suit && H.wear_suit.breakouttime) //straight jacket
				continue
			if(istype(H.loc, /obj/structure/closet)) //locked/welded locker, all aboard the clown train honk honk
				var/obj/structure/closet/C = H.loc
				if(C.welded || C.locked)
					continue
		var/special_role = player.mind.special_role
		if(special_role)
			// There's a long list of special roles, but almost all of them are antags anyway.
			// If you manage to escape with a pet slaughter demon - go for it! Greentext well earned!
			if(special_role != SPECIAL_ROLE_EVENTMISC && special_role != SPECIAL_ROLE_ERT && special_role != SPECIAL_ROLE_DEATHSQUAD)
				continue

		if(get_area(player) == areaInstance)
			return FALSE

	return TRUE


/obj/docking_port/mobile/emergency/check()
	if(!timer)
		return

	var/time_left = timeLeft(1)

	// The emergency shuttle doesn't work like others so this
	// ripple check is slightly different
	if(!ripples.len && (time_left <= SHUTTLE_RIPPLE_TIME) && ((mode == SHUTTLE_CALL) || (mode == SHUTTLE_ESCAPE)))
		var/destination
		if(mode == SHUTTLE_CALL)
			destination = SSshuttle.getDock("emergency_home")
		else if(mode == SHUTTLE_ESCAPE)
			destination = SSshuttle.getDock("emergency_away")
		create_ripples(destination)

	switch(mode)
		if(SHUTTLE_RECALL)
			if(time_left <= 0)
				mode = SHUTTLE_IDLE
				timer = 0
		if(SHUTTLE_CALL)
			if(time_left <= 0)
				//move emergency shuttle to station
				if(dock(SSshuttle.getDock("emergency_home")))
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

			if(time_left <= 0 && SSshuttle.emergencyNoEscape)
				GLOB.priority_announcement.Announce("Hostile environment detected. Departure has been postponed indefinitely pending conflict resolution.")
				sound_played = 0
				mode = SHUTTLE_STRANDED

			if(time_left <= 50 && !sound_played) //4 seconds left - should sync up with the launch
				sound_played = 1
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_begin.ogg'

			if(time_left <= 0 && !SSshuttle.emergencyNoEscape)
				//move each escape pod to its corresponding transit dock
				for(var/obj/docking_port/mobile/pod/M in SSshuttle.mobile)
					if(is_station_level(M.z)) //Will not launch from the mine/planet
						M.enterTransit()
				//now move the actual emergency shuttle to its transit dock
				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_progress.ogg'
				enterTransit()
				mode = SHUTTLE_ESCAPE
				timer = world.time
				GLOB.priority_announcement.Announce("The Emergency Shuttle has left the station. Estimate [timeLeft(600)] minutes until the shuttle docks at Central Command.")
				for(var/mob/M in GLOB.player_list)
					if(!isnewplayer(M) && !M.client.karma_spent && !(M.client.ckey in GLOB.karma_spenders) && !M.get_preference(DISABLE_KARMA_REMINDER))
						to_chat(M, "<i>You have not yet spent your karma for the round; was there a player worthy of receiving your reward? Look under Special Verbs tab, Award Karma.</i>")

		if(SHUTTLE_ESCAPE)
			if(time_left <= 0)
				//move each escape pod to its corresponding escape dock
				for(var/obj/docking_port/mobile/pod/M in SSshuttle.mobile)
					M.dock(SSshuttle.getDock("[M.id]_away"))

				for(var/area/shuttle/escape/E in world)
					E << 'sound/effects/hyperspace_end.ogg'

				// now move the actual emergency shuttle to centcomm
				// unless the shuttle is "hijacked"
				var/destination_dock = "emergency_away"
				if(is_hijacked())
					destination_dock = "emergency_syndicate"
					GLOB.priority_announcement.Announce("Corruption detected in shuttle navigation protocols. Please contact your supervisor.")

				dock_id(destination_dock)

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
		. = SSshuttle.getDock("[id]_transit")
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
	var/target_area = /area/mine/unexplored

/obj/docking_port/stationary/random/Initialize()
	..()
	var/list/turfs = get_area_turfs(target_area)
	var/turf/T = pick(turfs)
	src.loc = T

/obj/docking_port/mobile/emergency/backup
	name = "backup shuttle"
	id = "backup"
	dwidth = 2
	width = 8
	height = 8
	dir = 4

	roundstart_move = "backup_away"

/obj/docking_port/mobile/emergency/backup/register()
	var/current_emergency = SSshuttle.emergency
	..()
	SSshuttle.emergency = current_emergency
	SSshuttle.backup_shuttle = src
