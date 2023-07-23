GLOBAL_VAR_INIT(security_level, 0)
//0 = code green
//1 = code blue
//2 = code red
//3 = gamma
//4 = epsilon
//5 = code delta

//config.alert_desc_blue_downto
GLOBAL_DATUM_INIT(security_announcement, /datum/announcer, new(config_type = /datum/announcement_configuration/security))

/proc/set_security_level(level)
	switch(level)
		if("green")
			level = SEC_LEVEL_GREEN
		if("blue")
			level = SEC_LEVEL_BLUE
		if("red")
			level = SEC_LEVEL_RED
		if("gamma")
			level = SEC_LEVEL_GAMMA
		if("epsilon")
			level = SEC_LEVEL_EPSILON
		if("delta")
			level = SEC_LEVEL_DELTA

	if(level != SEC_LEVEL_DELTA)
		stop_delta_alarm()

	//Will not be announced if you try to set to the same level as it already is
	if(level >= SEC_LEVEL_GREEN && level <= SEC_LEVEL_DELTA && level != GLOB.security_level)
		if(level >= SEC_LEVEL_RED && GLOB.security_level < SEC_LEVEL_RED)
			// Mark down this time to prevent shuttle cheese
			SSshuttle.emergency_sec_level_time = world.time

		switch(level)
			if(SEC_LEVEL_GREEN)
				GLOB.security_announcement.Announce("All threats to the station have passed. All weapons need to be holstered and privacy laws are once again fully enforced.","Attention! Security level lowered to green.", new_sound2 = 'sound/AI/green.ogg')
				GLOB.security_level = SEC_LEVEL_GREEN
				unset_stationwide_emergency_lighting()
				post_status(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)
				update_firealarms()

			if(SEC_LEVEL_BLUE)
				if(GLOB.security_level < SEC_LEVEL_BLUE)
					GLOB.security_announcement.Announce("The station has received reliable information about possible hostile activity on the station. Security staff may have weapons visible and random searches are permitted.", "Attention! Security level elevated to blue.",
					new_sound = 'sound/misc/notice1.ogg',
					new_sound2 = 'sound/AI/blue.ogg')
				else
					GLOB.security_announcement.Announce("The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed.", "Attention! Security level lowered to blue.", new_sound2 = 'sound/AI/blue.ogg')
				GLOB.security_level = SEC_LEVEL_BLUE

				post_status(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)
				unset_stationwide_emergency_lighting()
				update_firealarms()

			if(SEC_LEVEL_RED)
				if(GLOB.security_level < SEC_LEVEL_RED)
					GLOB.security_announcement.Announce("There is an immediate and serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised.", "Attention! Code Red!",
					new_sound = 'sound/misc/notice1.ogg',
					new_sound2 = 'sound/AI/red.ogg')
				else
					GLOB.security_announcement.Announce("The station's self-destruct mechanism has been deactivated, but there is still an immediate and serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised.", "Attention! Code Red!", new_sound2 = 'sound/AI/red.ogg')
					unset_stationwide_emergency_lighting()
				GLOB.security_level = SEC_LEVEL_RED

				var/obj/machinery/door/airlock/highsecurity/red/R = locate(/obj/machinery/door/airlock/highsecurity/red) in GLOB.airlocks
				if(R && is_station_level(R.z))
					R.unlock(TRUE)

				post_status(STATUS_DISPLAY_ALERT, "redalert")
				update_firealarms()

			if(SEC_LEVEL_GAMMA)
				GLOB.security_announcement.Announce("Central Command has ordered the Gamma security level on the station. Security is to have weapons equipped at all times, and all civilians are to immediately seek their nearest head for transportation to a secure location.", "Attention! Gamma security level activated!", 'sound/effects/new_siren.ogg', new_sound2 = 'sound/AI/gamma.ogg')
				GLOB.security_level = SEC_LEVEL_GAMMA

				if(GLOB.security_level < SEC_LEVEL_RED)
					for(var/obj/machinery/door/airlock/highsecurity/red/R in GLOB.airlocks)
						if(is_station_level(R.z))
							R.unlock(TRUE)

				post_status(STATUS_DISPLAY_ALERT, "gammaalert")
				update_firealarms()

			if(SEC_LEVEL_EPSILON)
				for(var/mob/M in GLOB.player_list)
					var/turf/T = get_turf(M)
					if(!M.client || !is_station_level(T.z))
						continue
					SEND_SOUND(M, sound('sound/effects/powerloss.ogg'))
				set_stationwide_emergency_lighting()
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(epsilon_process)), 15 SECONDS)
				SSblackbox.record_feedback("tally", "security_level_changes", 1, level)
				return

			if(SEC_LEVEL_DELTA)
				var/temp_sound = GLOB.security_announcement.config.sound
				GLOB.security_announcement.config.sound = null
				GLOB.security_announcement.Announce("The station's self-destruct mechanism has been engaged. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill.","Attention! Delta security level reached!",
					new_sound = null,
					new_sound2 = null)
				GLOB.security_announcement.config.sound = temp_sound
				GLOB.security_level = SEC_LEVEL_DELTA
				post_status(STATUS_DISPLAY_ALERT, "deltaalert")
				update_firealarms()
				set_stationwide_emergency_lighting()
				delta_alarm()
				SSblackbox.record_feedback("tally", "security_level_changes", 1, level)
				return

		SSnightshift.check_nightshift(TRUE)
		SSblackbox.record_feedback("tally", "security_level_changes", 1, level)

	else
		return

/proc/get_security_level()
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_GAMMA)
			return "gamma"
		if(SEC_LEVEL_EPSILON)
			return "epsilon"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/update_firealarms()
	for(var/obj/machinery/firealarm/FA in GLOB.machines)
		if(is_station_contact(FA.z))
			FA.update_icon()
			FA.update_fire_light()

/proc/num2seclevel(num)
	switch(num)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_GAMMA)
			return "gamma"
		if(SEC_LEVEL_EPSILON)
			return "epsilon"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/seclevel2num(seclevel)
	switch( lowertext(seclevel) )
		if("green")
			return SEC_LEVEL_GREEN
		if("blue")
			return SEC_LEVEL_BLUE
		if("red")
			return SEC_LEVEL_RED
		if("gamma")
			return SEC_LEVEL_GAMMA
		if("epsilon")
			return SEC_LEVEL_EPSILON
		if("delta")
			return SEC_LEVEL_DELTA

/proc/get_security_level_colors()
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			return "<font color='limegreen'>Green</font>"
		if(SEC_LEVEL_BLUE)
			return "<font color='dodgerblue'>Blue</font>"
		if(SEC_LEVEL_RED)
			return "<font color='red'>Red</font>"
		if(SEC_LEVEL_GAMMA)
			return "<font color='gold'>Gamma</font>"
		if(SEC_LEVEL_EPSILON)
			return "<font color='blueviolet'>Epsilon</font>"
		if(SEC_LEVEL_DELTA)
			return "<font color='orangered'>Delta</font>"

/proc/set_stationwide_emergency_lighting()
	for(var/obj/machinery/power/apc/A in GLOB.apcs)
		var/area/AR = get_area(A)
		if(!is_station_level(A.z))
			continue
		A.emergency_lights = FALSE
		AR.area_emergency_mode = TRUE
		for(var/obj/machinery/light/L in A.apc_area)
			if(L.status)
				continue
			if(GLOB.security_level == SEC_LEVEL_DELTA)
				L.fire_mode = TRUE
			L.on = FALSE
			L.emergency_mode = TRUE
			INVOKE_ASYNC(L, TYPE_PROC_REF(/obj/machinery/light, update), FALSE)

/proc/unset_stationwide_emergency_lighting()
	for(var/area/A as anything in GLOB.all_areas)
		if(!is_station_level(A.z))
			continue
		if(!A.area_emergency_mode)
			continue
		A.area_emergency_mode = FALSE
		for(var/obj/machinery/light/L in A)
			if(A.fire)
				continue
			if(L.status)
				continue
			L.fire_mode = FALSE
			L.emergency_mode = FALSE
			L.on = TRUE
			INVOKE_ASYNC(L, TYPE_PROC_REF(/obj/machinery/light, update), FALSE)

/proc/epsilon_process()
	GLOB.security_announcement.Announce("Central Command has ordered the Epsilon security level on the station. Consider all contracts terminated.", "Attention! Epsilon security level activated!", 'sound/effects/purge_siren.ogg')
	GLOB.security_level = SEC_LEVEL_EPSILON
	post_status(STATUS_DISPLAY_ALERT, "epsilonalert")
	for(var/area/A as anything in GLOB.all_areas)
		if(!is_station_level(A.z))
			continue
		for(var/obj/machinery/light/L in A)
			if(L.status)
				continue
			L.fire_mode = TRUE
			L.update()
	update_firealarms()

/proc/delta_alarm()
	var/station_z = level_name_to_num(MAIN_STATION)
	var/list/mobs_for_alarm = list()

	for(var/mob/M in get_mob_with_client_list())
		if(M.z != station_z)
			continue

		mobs_for_alarm += M

	var/datum/looping_sound/decreasing/delta_alarm/alarm = new(_output_atoms = mobs_for_alarm, _direct = TRUE)
	alarm.channel = CHANNEL_DELTA_ALARM
	alarm.start()

/proc/stop_delta_alarm()
	for(var/datum/looping_sound/decreasing/delta_alarm/alarm in GLOB.looping_sounds)
		for(var/mob/hearer in alarm.output_atoms) // Immediately stop the alarm for anyone who can hear it.
			hearer.stop_sound_channel(CHANNEL_DELTA_ALARM)
		qdel(alarm)
