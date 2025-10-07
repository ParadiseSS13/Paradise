#define POWER_RESTORATION_OFF 0
#define POWER_RESTORATION_START 1
#define POWER_RESTORATION_SEARCH_APC 2
#define POWER_RESTORATION_APC_FOUND 3

/mob/living/silicon/ai/Life(seconds, times_fired)
	//doesn't call parent because it's a horrible mess
	if(stat == DEAD)
		return

	var/turf/T = get_turf(src)
	if(stat != CONSCIOUS) //ai's fucked
		camera_follow = null
		reset_perspective(null)
		unset_machine()

	updatehealth("life")
	if(stat == DEAD)
		return
	update_gravity(mob_has_gravity())

	if(!eyeobj || QDELETED(eyeobj) || !eyeobj.loc)
		view_core()

	// Do holopad AI checks
	if(istype(machine, /obj/machinery/hologram))
		check_holopad_eye()

	// Enhanced Tracking
	if(enhanced_tracking && tracked_mob && !tracker_alert_cooldown)
		if(can_see(tracked_mob))
			var/area/A = get_area(tracked_mob)
			if(A)
				addtimer(CALLBACK(src, PROC_REF(raise_tracking_alert), A, tracked_mob), enhanced_tracking_delay)
				// To prevent spam, start a cooldown.
				tracker_alert_cooldown = TRUE
				addtimer(CALLBACK(src, PROC_REF(reset_tracker_cooldown)), tracking_alert_interval)

	if(malfhack && malfhack.aidisabled)
		to_chat(src, "<span class='danger'>ERROR: APC access disabled, hack attempt canceled.</span>")
		deltimer(malfhacking)
		// This proc handles cleanup of screen notifications and
		// messenging the client
		malfhacked(malfhack)

	if(aiRestorePowerRoutine)
		adjustOxyLoss(1)
	else
		adjustOxyLoss(-1)

	var/area/my_area = get_area(src)

	if(!lacks_power())
		if(aiRestorePowerRoutine > 1)
			update_blind_effects()
			aiRestorePowerRoutine = 0
			update_sight()
			to_chat(src, "Alert cancelled. Power has been restored[aiRestorePowerRoutine == 2 ? "without our assistance" : ""].")
			apc_override = FALSE
	else
		if(lacks_power())
			if(!aiRestorePowerRoutine)
				update_blind_effects()
				aiRestorePowerRoutine = 1
				update_sight()
				to_chat(src, "<span class='danger'>You have lost power!</span>")
				if(!is_special_character(src))
					set_zeroth_law("")

				spawn(20)
					to_chat(src, "Backup battery online. Scanners, camera, and radio interface offline. Beginning fault-detection.")
					sleep(50)
					my_area = get_area(src)
					T = get_turf(src)
					if(!lacks_power())
						to_chat(src, "Alert cancelled. Power has been restored without our assistance.")
						aiRestorePowerRoutine = 0
						update_blind_effects()
						update_sight()
						return
					to_chat(src, "Fault confirmed: missing external power. Shutting down main control system to save power.")
					sleep(20)
					to_chat(src, "Emergency control system online. Verifying connection to power network.")
					sleep(50)
					T = get_turf(src)
					if(isspaceturf(T))
						to_chat(src, "Unable to verify! No power connection detected!")
						aiRestorePowerRoutine = 2
						return
					to_chat(src, "Connection verified. Searching for APC in power network.")
					sleep(50)

					my_area = get_area(src)
					T = get_turf(src)

					var/obj/machinery/power/apc/theAPC = null

					var/PRP
					for(PRP = 1, PRP <= 4, PRP++)
						for(var/obj/machinery/power/apc/APC in my_area)
							if(!(APC.stat & BROKEN))
								theAPC = APC
								break

						if(!theAPC)
							switch(PRP)
								if(1)
									to_chat(src, "Unable to locate APC!")
								else
									to_chat(src, "Lost connection with the APC!")
							aiRestorePowerRoutine = 2
							return

						if(!lacks_power())
							to_chat(src, "Alert cancelled. Power has been restored without our assistance.")
							aiRestorePowerRoutine = 0
							update_blind_effects()
							update_sight()
							to_chat(src, "Here are your current laws:")
							show_laws()
							return

						switch(PRP)
							if(1)
								to_chat(src, "APC located. Optimizing route to APC to avoid needless power waste.")
							if(2)
								to_chat(src, "Best route identified. Hacking offline APC power port.")
							if(3)
								to_chat(src, "Power port upload access confirmed. Loading control program into APC power port software.")
							if(4)
								to_chat(src, "Transfer complete. Forcing APC to execute program.")
								sleep(50)
								to_chat(src, "Receiving control information from APC.")
								sleep(2)
								//bring up APC dialog
								apc_override = TRUE
								theAPC.attack_ai(src)
								aiRestorePowerRoutine = 3
						sleep(50)
						theAPC = null

/mob/living/silicon/ai/updatehealth(reason = "none given")
	if(status_flags & GODMODE)
		health = 100
		set_stat(CONSCIOUS)
	else
		health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
		update_stat("updatehealth([reason])")
		diag_hud_set_health()


/mob/living/silicon/ai/proc/lacks_power()
	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	if(controlled_mech)
		return controlled_mech.get_charge() <= 0
	return (!A.powernet.equipment_powered && A.requires_power || isspaceturf(T)) && !isitem(loc)

/mob/living/silicon/ai/rejuvenate()
	..()
	add_ai_verbs(src)

#undef POWER_RESTORATION_OFF
#undef POWER_RESTORATION_START
#undef POWER_RESTORATION_SEARCH_APC
#undef POWER_RESTORATION_APC_FOUND
