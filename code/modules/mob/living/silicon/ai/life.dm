/mob/living/silicon/ai/Life()
	//doesn't call parent because it's a horrible mess
	if(stat == DEAD)
		return

	var/turf/T = get_turf(src)
	if(stat != CONSCIOUS) //ai's fucked
		cameraFollow = null
		reset_view(null)
		unset_machine()

	updatehealth()
	update_gravity(mob_has_gravity())

	if (health <= config.health_threshold_dead)
		death()
		return 0

	if(malfhack)
		if(malfhack.aidisabled)
			src << "<span class='danger'>ERROR: APC access disabled, hack attempt canceled.</span>"
			malfhacking = 0
			malfhack = null

	if(aiRestorePowerRoutine)
		adjustOxyLoss(1)
	else
		adjustOxyLoss(-1)

	handle_stunned()

	var/is_blind = 0 //THIS WAS JUST FUCKING 'blind' WHICH CONFLICTED WITH A NORMAL VARIABLE
	var/area/my_area = get_area(src)
	if(istype(my_area))
		if(!my_area.power_equip && !is_type_in_list(loc, list(/obj/item, /obj/mecha)))
			is_blind = 1 //HOW THE FUCK DID THAT EVEN COMPILE JESUS CHRIST

	if(!is_blind)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS

		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO

		if(see_override)
			see_invisible = see_override

		if(aiRestorePowerRoutine == 2)
			src << "Alert cancelled. Power has been restored without our assistance."
			aiRestorePowerRoutine = 0
			blind.layer = 0
		else if(aiRestorePowerRoutine == 3)
			src << "Alert cancelled. Power has been restored."
			aiRestorePowerRoutine = 0
			blind.layer = 0

		return

	else

		blind.screen_loc = "1,1 to 15,15"
		if(blind.layer != 18)
			blind.layer = 18
		sight &= ~SEE_TURFS
		sight &= ~SEE_MOBS
		sight &= ~SEE_OBJS

		see_in_dark = 0
		see_invisible = SEE_INVISIBLE_LIVING

		if(((!my_area.power_equip) || istype(T, /turf/space)) && !is_type_in_list(loc, list(/obj/item, /obj/mecha)))
			if(!aiRestorePowerRoutine)
				aiRestorePowerRoutine = 1

				src << "<span class='danger'>You have lost power!</span>"

				if(!is_special_character(src))
					set_zeroth_law("")

				spawn(20)
					src << "Backup battery online. Scanners, camera, and radio interface offline. Beginning fault-detection."
					sleep(50)
					my_area = get_area(src)
					T = get_turf(src)
					if(my_area && my_area.power_equip && !istype(T, /turf/space))
						src << "Alert cancelled. Power has been restored without our assistance."
						aiRestorePowerRoutine = 0
						blind.layer = 0
						return
					src << "Fault confirmed: missing external power. Shutting down main control system to save power."
					sleep(20)
					src << "Emergency control system online. Verifying connection to power network."
					sleep(50)
					T = get_turf(src)
					if(istype(T, /turf/space))
						src << "Unable to verify! No power connection detected!"
						aiRestorePowerRoutine = 2
						return
					src << "Connection verified. Searching for APC in power network."
					sleep(50)

					my_area = get_area(src)
					T = get_turf(src)

					var/obj/machinery/power/apc/theAPC = null

					var/PRP
					for(PRP = 1, PRP <= 4, PRP++)
						for(var/obj/machinery/power/apc/APC in my_area)
							if (!(APC.stat & BROKEN))
								theAPC = APC
								break

						if(!theAPC)
							switch(PRP)
								if(1) src << "Unable to locate APC!"
								else src << "Lost connection with the APC!"
							aiRestorePowerRoutine = 2
							return

						if(my_area.power_equip)
							if (!istype(T, /turf/space))
								src << "Alert cancelled. Power has been restored without our assistance."
								aiRestorePowerRoutine = 0
								blind.layer = 0
								return

						switch(PRP)
							if(1) src << "APC located. Optimizing route to APC to avoid needless power waste."
							if(2) src << "Best route identified. Hacking offline APC power port."
							if(3) src << "Power port upload access confirmed. Loading control program into APC power port software."
							if(4)
								src << "Transfer complete. Forcing APC to execute program."
								sleep(50)
								src << "Receiving control information from APC."
								sleep(2)
								//bring up APC dialog
								apc_override = 1
								theAPC.attack_ai(src)
								apc_override = 0
								aiRestorePowerRoutine = 3
								src << "Here are your current laws:"
								src.show_laws() //WHY THE FUCK IS THIS HERE
						sleep(50)
						theAPC = null

	process_queued_alarms()
	regular_hud_updates()

	switch(sensor_mode)
		if (SEC_HUD)
			process_sec_hud(src, 1, eyeobj)
		if (MED_HUD)
			process_med_hud(src, 1, eyeobj)

/mob/living/silicon/ai/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		if(fire_res_on_core)
			health = 100 - getOxyLoss() - getToxLoss() - getBruteLoss()
		else
			health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()

/mob/living/silicon/ai/proc/lacks_power()
	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	return ((!A.power_equip) && A.requires_power == 1 || istype(T, /turf/space)) && !istype(src.loc,/obj/item)

/mob/living/silicon/ai/rejuvenate()
	..()
	add_ai_verbs(src)