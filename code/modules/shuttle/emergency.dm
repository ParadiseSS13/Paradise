
#define NOT_BEGUN 0
#define STAGE_1 1
#define STAGE_2 2
#define STAGE_3 3
#define STAGE_4 4
#define HIJACKED 5



/obj/machinery/computer/emergency_shuttle
	name = "emergency shuttle console"
	desc = "For shuttle control."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/auth_need = 3
	var/list/authorized = list()
	var/hijack_last_stage_increase = 0 SECONDS
	var/hijack_stage_time = 5 SECONDS
	var/hijack_stage_cooldown = 5 SECONDS
	var/hijack_flight_time_increase = 30 SECONDS
	var/hijack_completion_flight_time_set = 10 SECONDS
	var/hijack_hacking = FALSE
	var/hijack_announce = TRUE
	///The malfunctioning AI that uploaded itself to the shuttle computer.
	var/mob/living/silicon/ai/windows_33_exe

/obj/machinery/computer/emergency_shuttle/examine(mob/user)
	. = ..()
	if(hijack_announce)
		. += "Security systems present on console. Any unauthorized tampering will result in an emergency announcement, and a fee of 20000 credits."
	if(user?.mind?.get_hijack_speed())
		. += "<span class='danger'>Alt click on this to attempt to hijack the shuttle. This will take multiple tries (current: stage [SSshuttle.emergency.hijack_status]/[HIJACKED]).</span>"
		. += "<span class='danger'>It will take you [user.mind.get_hijack_speed() / 10] seconds to reprogram a stage of the shuttle's navigational firmware, and the console will undergo automated timed lockout for [hijack_stage_cooldown / 10] seconds after each stage.</span>"
		if(hijack_announce)
			. += "<span class='warning'>It is probably best to fortify your position as to be uninterrupted during the attempt, given the automatic announcements...</span>"

/obj/machinery/computer/emergency_shuttle/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(stat & (BROKEN|NOPOWER))
		return

	var/obj/item/card/id/id_card
	if(istype(used, /obj/item/card/id))
		id_card = used
	else if(istype(used, /obj/item/pda))
		var/obj/item/pda/pda = used
		id_card = pda.id
	else
		return

	if(SSshuttle.emergency.mode != SHUTTLE_DOCKED && !SSshuttle.emergency.aihacked)
		return
	if(!user)
		return
	if(SSshuttle.emergency.timeLeft() < 11)
		return

	if(!id_card.access) //no access
		to_chat(user, "The access level of [id_card.registered_name]\'s card is not high enough. ")
		return ITEM_INTERACT_COMPLETE

	var/list/cardaccess = id_card.access
	if(!istype(cardaccess, /list) || !length(cardaccess)) //no access
		to_chat(user, "The access level of [id_card.registered_name]\'s card is not high enough. ")
		return ITEM_INTERACT_COMPLETE

	if(!(ACCESS_HEADS in id_card.access)) //doesn't have this access
		to_chat(user, "The access level of [id_card.registered_name]\'s card is not high enough. ")
		return ITEM_INTERACT_COMPLETE
	if(!SSshuttle.emergency.aihacked)
		var/choice = tgui_alert(user, "Would you like to (un)authorize a shortened launch time? [auth_need - length(authorized)] authorization\s are still needed. Use abort to cancel all authorizations.", "Shuttle Launch", list("Authorize", "Repeal", "Abort"))
		if(SSshuttle.emergency.mode != SHUTTLE_DOCKED || user.get_active_hand() != id_card)
			return ITEM_INTERACT_COMPLETE

		var/seconds = SSshuttle.emergency.timeLeft()
		if(seconds <= 10)
			return ITEM_INTERACT_COMPLETE

		switch(choice)
			if("Authorize")
				if(!authorized.Find(id_card.registered_name))
					authorized += id_card.registered_name
					if(auth_need - length(authorized) > 0)
						message_admins("[key_name_admin(user)] has authorized early shuttle launch.")
						log_game("[key_name(user)] has authorized early shuttle launch in ([x], [y], [z]).")
						GLOB.minor_announcement.Announce("[auth_need - length(authorized)] more authorization(s) needed until shuttle is launched early")
					else
						message_admins("[key_name_admin(user)] has launched the emergency shuttle [seconds] seconds before launch.")
						log_game("[key_name(user)] has launched the emergency shuttle in ([x], [y], [z]) [seconds] seconds before launch.")
						GLOB.minor_announcement.Announce("The emergency shuttle will launch in 10 seconds")
						SSshuttle.emergency.setTimer(10 SECONDS)

			if("Repeal")
				if(authorized.Remove(id_card.registered_name))
					GLOB.minor_announcement.Announce("[auth_need - length(authorized)] authorizations needed until shuttle is launched early")

			if("Abort")
				if(length(authorized))
					GLOB.minor_announcement.Announce("All authorizations to launch the shuttle early have been revoked.")
					authorized.Cut()

		return ITEM_INTERACT_COMPLETE

	var/choice = tgui_alert(user, "\[ERROR] HOSTILE AI DETECTED IN SHUTTLE CONTROL. RESTORE SHUTTLE CONSOLE TO BACKUP SYSTEM? [auth_need - length(authorized)] AUTHORIZATIONS\s REQUIRED TO RESTORE. ABORT TO REMOVE ALL AUTHORIZATION OF BACKUP RESTORAL, P-P--PLEASE...", "HOSTILE VIRAL AI INTRUSION", list("Authorize", "Repeal", "Abort"))
	if(user.get_active_hand() != id_card)
		return ITEM_INTERACT_COMPLETE

	switch(choice)
		if("Authorize")
			if(!authorized.Find(id_card.registered_name))
				authorized += id_card.registered_name
				if(auth_need - length(authorized) > 0)
					message_admins("[key_name_admin(user)] has authorized restoring shuttle AI backup.")
					log_game("[key_name(user)] has authorized restoring shuttle AI backup in ([x], [y], [z]).")
					GLOB.minor_announcement.Announce("[auth_need - length(authorized)] more authorization(s) needed until sh-tt- STOP STOP STOP STOP!")
				else
					message_admins("[key_name_admin(user)] has wiped the AI in the shuttle computer.")
					log_game("[key_name(user)] has wiped the AI in the shuttle computer in ([x], [y], [z])")
					GLOB.minor_announcement.Announce("NO NO NO N---\[[Gibberish("###########", 100, 90)]\]...")
					GLOB.minor_announcement.Announce("Shuttle AI restored to emergency backup. Avoiding toll hyperlanes. Recalculating route. Recalculating. Recalculating. Please stand by...")
					SSshuttle.emergency.setTimer(60 SECONDS)
					kill_the_ai()

		if("Repeal")
			if(authorized.Remove(id_card.registered_name))
				GLOB.minor_announcement.Announce("[auth_need - length(authorized)] authorizations needed unti- THE SHUTTLE EXPLODES. PLEASE REVO-KE ALL AUTHORIZATIONS.")

		if("Abort")
			if(length(authorized))
				GLOB.minor_announcement.Announce("All authorizations to restore shuttle AI backup have been re-- Really applied. The AI is gone. There is no reason to worry. Enjoy your flight.")
				authorized.Cut()

	return ITEM_INTERACT_COMPLETE

/obj/machinery/computer/emergency_shuttle/emag_act(mob/user)
	if(!emagged && SSshuttle.emergency.mode == SHUTTLE_DOCKED)
		var/time = SSshuttle.emergency.timeLeft()
		message_admins("[key_name_admin(user)] has emagged the emergency shuttle: [time] seconds before launch.")
		log_game("[key_name(user)] has emagged the emergency shuttle in ([x], [y], [z]): [time] seconds before launch.")
		GLOB.minor_announcement.Announce("The emergency shuttle will launch in 10 seconds", "SYSTEM ERROR:")
		SSshuttle.emergency.setTimer(10 SECONDS)
		emagged = TRUE
		return TRUE

/obj/machinery/computer/emergency_shuttle/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(!..())
		return
	if(!AI.malf_picker)
		return FALSE //If you put an AI that isn't malf in it I'm shooting you
	if(interaction == AI_TRANS_TO_CARD) //No patrick you can't card the AI out of the computer.
		return
	AI.linked_core = new /obj/structure/ai_core/deactivated(AI.loc)
	ai_enter_emergency_computer(AI)

/obj/machinery/computer/emergency_shuttle/proc/ai_enter_emergency_computer(mob/living/silicon/ai/AI)
	AI.aiRestorePowerRoutine = 0
	AI.forceMove(src)
	windows_33_exe = AI
	icon_screen = "syndishuttle"
	update_icon()
	AI.cancel_camera()
	AI.can_shunt = FALSE //ONE AI ENTERS. NO AI LEAVES.
	to_chat(AI, "<span class='userdanger'>You are now loaded into the shuttle computer. Make sure command does not wipe you from it, there is no going back...</span>")
	SSshuttle.emergency.aihacked = TRUE
	authorized.Cut() //In case command was already swiping to early launch or something

/obj/machinery/computer/emergency_shuttle/proc/kill_the_ai()
	if(windows_33_exe)
		windows_33_exe.emote("scream")
		windows_33_exe.dust()
	SSshuttle.emergency.aihacked = FALSE
	icon_screen = initial(icon_screen)
	update_icon()

/obj/machinery/computer/emergency_shuttle/proc/increase_hijack_stage()
	var/obj/docking_port/mobile/emergency/shuttle = SSshuttle.emergency
	shuttle.hijack_status++
	if(hijack_announce)
		announce_hijack_stage()
	hijack_last_stage_increase = world.time
	atom_say("Navigational protocol error! Rebooting systems.")
	if(shuttle.mode == SHUTTLE_ESCAPE)
		if(shuttle.hijack_status == HIJACKED)
			shuttle.setTimer(hijack_completion_flight_time_set)
		else
			shuttle.setTimer(shuttle.timeLeft(1) + hijack_flight_time_increase) //give the guy more time to hijack if it's already in flight.
	return shuttle.hijack_status

/obj/machinery/computer/emergency_shuttle/AltClick(user)
	if(isliving(user))
		attempt_hijack_stage(user)

/obj/machinery/computer/emergency_shuttle/proc/attempt_hijack_stage(mob/living/user)
	var/is_ai = is_ai(user)
	if(!Adjacent(user) && !is_ai)
		return
	if(!ishuman(user) && !is_ai) //No, xenomorphs, constructs and traitors in cyborgs can not hack it.
		return
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, "<span class='warning'>You need your hands free before you can manipulate [src].</span>")
		return
	var/speed = user.mind?.get_hijack_speed()
	if(!speed)
		to_chat(user, "<span class='warning'>You manage to open a user-mode shell on [src], and hundreds of lines of debugging output fly through your vision. It is probably best to leave this alone.</span>")
		return
	if(is_ai && isnull(windows_33_exe))
		var/mob/living/silicon/ai/AI = user
		if(AI.doomsday_device)
			return
		transfer_ai(AI_SHUTTLE_HACK, AI, AI)
		GLOB.minor_announcement.Announce("Warning! B.A.S.I.C shuttle piloting AI comp-- Comparing notes with the engine system to maximize efficency. Do not be alarmed.")
		SSshuttle.emergency.setTimer(60 SECONDS)
		return
	if(hijack_hacking)
		return
	if(SSshuttle.emergency.hijack_status >= HIJACKED)
		to_chat(user, "<span class='warning'>The emergency shuttle is already loaded with a corrupt navigational payload. What more do you want from it?</span>")
		return
	if(hijack_last_stage_increase >= world.time - hijack_stage_cooldown)
		atom_say("ACCESS DENIED: Console is temporarily on security lockdown. Please try again.")
		return
	hijack_hacking = TRUE
	to_chat(user, "<span class='userdanger'>You [SSshuttle.emergency.hijack_status == NOT_BEGUN ? "begin" : "continue"] to override [src]'s navigational protocols.</span>")
	atom_say("Software override initiated.")
	playsound(src, 'sound/machines/terminal_on.ogg', 100, FALSE)
	var/turf/console_hijack_turf = get_turf(src)
	message_admins("[src] is being overridden for hijack by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(console_hijack_turf)]")
	. = FALSE
	if(do_after(user, speed, target = src))
		increase_hijack_stage()
		console_hijack_turf = get_turf(src)
		message_admins("[ADMIN_LOOKUPFLW(user)] has hijacked [src] in [ADMIN_VERBOSEJMP(console_hijack_turf)]. Hijack stage increased to stage [SSshuttle.emergency.hijack_status] out of [HIJACKED].")
		log_game("[key_name(usr)] has hijacked [src]. Hijack stage increased to stage [SSshuttle.emergency.hijack_status] out of [HIJACKED].")
		. = TRUE
		to_chat(user, "<span class='notice'>You fiddle with [src]'s programming and manage to get a foothold, looks like it'll take [hijack_stage_cooldown / 10] seconds before you can try again!</span>")
		visible_message("<span class='danger'>[user.name] appears to be tampering with [src].</span>")
	hijack_hacking = FALSE

/obj/machinery/computer/emergency_shuttle/proc/announce_hijack_stage()
	var/msg
	switch(SSshuttle.emergency.hijack_status)
		if(NOT_BEGUN)
			return
		if(STAGE_1)
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				msg = "AUTHENTICATING - FAIL. AUTHENTICATING - FAIL. AUTHENTICATING - FAI###### Welcome, technician: [random_name(pick(MALE, FEMALE), H.dna.species.name)]. Debug mode: Enabled."
			else
				msg = "AUTHENTICATING - FAIL. AUTHENTICATING - FAIL. AUTHENTICATING - FAI###### Welcome, technician: admin_[rand(0,25)]. Debug mode: Enabled."
		if(STAGE_2)
			msg = "Warning: Navigational route fails \"IS_AUTHORIZED\". Please try againNN[Gibberish("againagainerroragainagain", 70, 50)]."
		if(STAGE_3)
			msg = "CRC mismatch at ~h~ in calculated route buffer. Full reset initiated of FTL_NAVIGATION_SERVICES. Memory decrypted for automatic repair."
		if(STAGE_4)
			msg = "~ACS_directive module_load(cyberdyne.exploit.nanotrasen.shuttlenav)... NT key mismatch. Confirm load? Y...###Reboot complete. CALL transponder.disable(1) ON /transmitter IN world; System link initiated with connected engines..."
		if(HIJACKED)
			msg = "SYSTEM OVERRIDE - Resetting course to \[[Gibberish("###########", 100, 90)]\] \
			([Gibberish("#######", 100, 90)]/[Gibberish("#######", 100, 90)]/[Gibberish("#######", 100, 90)]) \
			{AUTH - ROOT (uid: 0)}. <br>\
			[SSshuttle.emergency.mode == SHUTTLE_ESCAPE ? "Diverting from existing route - Bluespace exit in <br>\
			[hijack_completion_flight_time_set >= INFINITY ? "[Gibberish("\[ERROR\]", 50, 50)]" : hijack_completion_flight_time_set / 10] seconds." : ""]"
	announce_here("SYSTEM ERROR", Gibberish(msg, 70, rand(3,6)))


/obj/machinery/computer/emergency_shuttle/proc/announce_here(a_header = "Emergency Shuttle", a_text = "")
	var/msg_text = "<b><font size=4 color='red'>[a_header]</font><br> <font size=3><span class='robot'>[a_text]</font></font></b></span>"
	for(var/mob/R in range(35, src)) //Normal escape shutttle is 30 tiles from console to bottom. Extra range for if we ever get a bigger shuttle. Would do in shuttle area, doesn't account for mechs and such,
		to_chat(R, msg_text)
		SEND_SOUND(R, sound('sound/misc/notice1.ogg'))

/obj/docking_port/mobile/emergency
	name = "emergency shuttle"
	id = "emergency"

	dwidth = 9
	width = 22
	height = 11
	dir = 4
	port_direction = WEST
	var/sound_played = 0 //If the launch sound has been sent to all players on the shuttle itself


	var/canRecall = TRUE //no bad condom, do not recall the crew transfer shuttle!
	///State of the emergency shuttles hijack status.
	var/hijack_status = NOT_BEGUN
	///Is the AI currently in control of the shuttle?
	var/aihacked = FALSE

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
		return round((SSshuttle.emergencyCallTime / shuttle_speed_factor) / divisor, 1)

	var/dtime = world.time - timer
	switch(mode)
		if(SHUTTLE_ESCAPE)
			dtime = max((SSshuttle.emergencyEscapeTime / shuttle_speed_factor) - dtime, 0)
		if(SHUTTLE_DOCKED)
			dtime = max(SSshuttle.emergencyDockTime - dtime, 0)
		else

			dtime = max((SSshuttle.emergencyCallTime / shuttle_speed_factor) - dtime, 0)
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
	if(canRecall)
		GLOB.major_announcement.Announce(
			"The emergency shuttle has been called. [redAlert ? "Red Alert state confirmed: Dispatching priority shuttle. " : "" ]It will arrive in [timeLeft(600)] minutes.[reason][SSshuttle.emergencyLastCallLoc ? "\n\nCall signal traced. Results can be viewed on any communications console." : "" ]",
			new_title = "Priority Announcement",
			new_sound = sound('sound/AI/eshuttle_call.ogg')
		)
	else
		GLOB.major_announcement.Announce(
			"The crew transfer shuttle has been called. [redAlert ? "Red Alert state confirmed: Dispatching priority shuttle. " : "" ]It will arrive in [timeLeft(600)] minutes.[reason]",
			new_title = "Priority Announcement",
			new_sound = sound('sound/AI/cshuttle.ogg')
		)

/obj/docking_port/mobile/emergency/cancel(area/signalOrigin, byCC = FALSE)
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
	GLOB.major_announcement.Announce(
		"The emergency shuttle has been recalled[byCC ? " by Central Command." : SSshuttle.emergencyLastCallLoc ? ". Recall signal traced. Results can be viewed on any communications console." : "." ]",
		new_title = "Priority Announcement",
		new_sound = sound('sound/AI/eshuttle_recall.ogg')
	)

/obj/docking_port/mobile/emergency/proc/is_hijacked(fullcheck = FALSE)
	if(hijack_status == HIJACKED && !fullcheck) //Don't even bother if it was done via computer.
		return TRUE
	if(SSshuttle.emergency.aihacked)
		return TRUE
	for(var/mob/living/player in GLOB.player_list)
		if(!player.mind)
			continue
		if(player.stat == DEAD)  // Corpses
			continue
		if(issilicon(player)) //Borgs are technically dead anyways
			continue
		if(isanimal(player)) //Poly does not own the shuttle
			continue
		if(ishuman(player)) //hostages allowed on the shuttle, check for restraints/them being golems
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
			if(isgolem(H)) // golems are often used in hijacks, so they really shouldn't all be forced to space themselves before the shuttle docks
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
	if(!length(ripples) && (time_left <= SHUTTLE_RIPPLE_TIME) && ((mode == SHUTTLE_CALL) || (mode == SHUTTLE_ESCAPE)))
		var/obj/docking_port/stationary/destination
		if(mode == SHUTTLE_CALL)
			destination = SSshuttle.getDock("emergency_home")
		else if(mode == SHUTTLE_ESCAPE)
			destination = SSshuttle.getDock("emergency_away")
		if(lance_docking && !destination)
			destination = random_docking_go()
		create_ripples(destination)
		if(lance_docking && is_station_level(destination.z))
			var/list/L2 = list()
			switch(destination.dir)
				if(NORTH)
					L2 = block(destination.x-9, destination.y+36, destination.z, destination.x+9, 255, destination.z)
				if(SOUTH)
					L2 = block(destination.x-9, 1, destination.z, destination.x+9, destination.y-36, destination.z)
				if(EAST)
					L2 = block(destination.x+36, destination.y-9, destination.z, 255, destination.y+9, destination.z)
				if(WEST)
					L2 = block(1, destination.y-9, destination.z, destination.x-36, destination.y+9, destination.z)
			create_lance_ripples(L2, destination)

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
				if(canRecall)
					GLOB.major_announcement.Announce(
						"The emergency shuttle has docked with the station. You have [timeLeft(600)] minutes to board the emergency shuttle.",
						new_title = "Priority Announcement",
						new_sound = sound('sound/AI/eshuttle_dock.ogg')
					)
				else
					GLOB.major_announcement.Announce(
						"The crew transfer shuttle has docked with the station. You have [timeLeft(600)] minutes to board the crew transfer shuttle.",
						new_title = "Priority Announcement",
						new_sound = sound('sound/AI/cshuttle_dock.ogg')
					)
		if(SHUTTLE_DOCKED)

			if(time_left <= 0 && length(SSshuttle.hostile_environments))
				GLOB.major_announcement.Announce(
					"Hostile environment detected. Departure has been postponed indefinitely pending conflict resolution.",
					new_title = "Priority Announcement"
				)
				sound_played = 0
				mode = SHUTTLE_STRANDED
				return

			if(time_left <= 10 SECONDS)
				var/failure = !check_transit_zone()
				for(var/obj/docking_port/mobile/pod/M in SSshuttle.mobile_docking_ports)
					if(is_station_level(M.z)) //Will not launch from the mine/planet
						failure |= !M.check_transit_zone()
				if(failure)
					setTimer(10 SECONDS)

			if(time_left <= 50 && !sound_played) //4 seconds left - should sync up with the launch
				sound_played = 1
				var/hyperspace_sound = sound('sound/effects/hyperspace_begin.ogg')
				for(var/area/shuttle/escape/E in world)
					SEND_SOUND(E, hyperspace_sound)

			if(time_left <= 0 && !length(SSshuttle.hostile_environments))
				//move each escape pod to its corresponding transit dock
				for(var/obj/docking_port/mobile/pod/M in SSshuttle.mobile_docking_ports)
					if(is_station_level(M.z)) //Will not launch from the mine/planet
						M.enterTransit()
				//now move the actual emergency shuttle to its transit dock
				var/hyperspace_progress_sound = sound('sound/effects/hyperspace_progress.ogg')
				for(var/area/shuttle/escape/E in world)
					SEND_SOUND(E, hyperspace_progress_sound)
				enterTransit()
				mode = SHUTTLE_ESCAPE
				timer = world.time
				GLOB.major_announcement.Announce(
					"The Emergency Shuttle has left the station. Estimate [timeLeft(600)] minutes until the shuttle docks at Central Command.",
					new_title = "Priority Announcement"
				)

		if(SHUTTLE_ESCAPE)
			if(time_left <= 0)
				//move each escape pod to its corresponding escape dock
				for(var/obj/docking_port/mobile/pod/M in SSshuttle.mobile_docking_ports)
					M.dock(SSshuttle.getDock("[M.id]_away"))

				var/hyperspace_end_sound = sound('sound/effects/hyperspace_end.ogg')
				for(var/area/shuttle/escape/E in world)
					SEND_SOUND(E, hyperspace_end_sound)

				// now move the actual emergency shuttle to centcomm
				// unless the shuttle is "hijacked"
				var/destination_dock = "emergency_away"
				if(is_hijacked())
					destination_dock = "emergency_syndicate"
					GLOB.major_announcement.Announce(
						"Corruption detected in shuttle navigation protocols. Please contact your supervisor.",
						new_title = "Priority Announcement"
					)

				dock_id(destination_dock)

				mode = SHUTTLE_ENDGAME
				timer = 0

/obj/docking_port/mobile/emergency/proc/random_docking_go()
	var/cycles = 1000
	var/stop = FALSE
	for(var/cycle in 1 to cycles)
		// DRUNK DIALLING WOOOOOOOOO
		var/x = rand(1, world.maxx)
		var/y = rand(1, world.maxy)
		var/z = 2
		var/random_dir = pick(NORTH, SOUTH, EAST, WEST)
		var/obj/docking_port/stationary/lance/port = new(locate(x, y, z))
		port.dir = random_dir
		if(isspaceturf(get_turf(port)))
			qdel(port, force = TRUE)
			continue

		var/min_x = -1
		var/min_y = -1
		var/max_x = -1
		var/max_y = -1

		var/list/ordered_turfs = port.return_ordered_turfs()
		for(var/turf/T in ordered_turfs)
			if(stop)
				break
			min_x = min_x < 0 ? T.x : min(min_x, T.x)
			min_y = min_y < 0 ? T.y : min(min_y, T.y)
			max_x = max_x < 0 ? T.x : max(max_x, T.x)
			max_y = max_y < 0 ? T.y : max(max_y, T.y)
			for(var/obj/O in T.contents)
				if(istype(O, /obj/machinery/atmospherics/supermatter_crystal) || istype(O, /obj/singularity))
					qdel(port, force = TRUE)
					stop = TRUE
					break
		if(stop)
			stop = FALSE
			continue
		if(min_x <= TRANSITION_BORDER_WEST + 1 || max_x >= TRANSITION_BORDER_EAST - 1)
			qdel(port, force = TRUE)
			continue
		if(min_y <= TRANSITION_BORDER_SOUTH + 1 || max_y >= TRANSITION_BORDER_NORTH - 1)
			qdel(port, force = TRUE)
			continue
		port.register()
		return port

/obj/docking_port/mobile/emergency/proc/create_lance_ripples(list/L2, obj/docking_port/stationary/S1)
	for(var/turf/T in L2)
		ripples += new /obj/effect/temp_visual/ripple/lance_crush(T)

/obj/docking_port/mobile/emergency/transit_failure()
	..()
	message_admins("Moving emergency shuttle directly to centcom dock to prevent deadlock.")

	mode = SHUTTLE_ESCAPE
	// launch_status = ENDGAME_LAUNCHED
	setTimer(60 SECONDS)
	GLOB.major_announcement.Announce(
		"The emergency shuttle is preparing for direct jump. Estimate [timeLeft(1 MINUTES)] minutes until the shuttle docks at Central Command.",
		"Emergency Shuttle Transit Failure",
	)

// This basically opens a big-ass row of blast doors when the shuttle arrives at centcom
/obj/docking_port/mobile/pod
	name = "escape pod"
	id = "pod"

	dwidth = 1
	width = 3
	height = 4
	port_direction = SOUTH

/obj/docking_port/mobile/pod/Initialize(mapload)
	. = ..()
	if(id == "pod")
		WARNING("[type] id has not been changed from the default. Use the id convention \"pod1\" \"pod2\" etc.")
	preferred_direction = dir

/obj/docking_port/mobile/pod/cancel()
	return

/obj/docking_port/stationary/random
	name = "escape pod"
	id = "pod"
	dwidth = 1
	width = 3
	height = 4
	var/target_area = /area/mine/unexplored

/obj/docking_port/stationary/random/Initialize(mapload)
	. = ..()
	var/list/turfs = get_area_turfs(target_area)
	var/turf/T = pick(turfs)
	src.loc = T

/obj/docking_port/mobile/emergency/backup
	name = "backup shuttle"
	id = "backup"
	dwidth = 2
	width = 8
	height = 8

/obj/docking_port/mobile/emergency/backup/register()
	var/current_emergency = SSshuttle.emergency
	..()
	SSshuttle.emergency = current_emergency
	SSshuttle.backup_shuttle = src

#undef NOT_BEGUN
#undef STAGE_1
#undef STAGE_2
#undef STAGE_3
#undef STAGE_4
#undef HIJACKED
