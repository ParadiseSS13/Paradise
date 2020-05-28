/datum/event/grid_check	//NOTE: Times are measured in master controller ticks!
	announceWhen		= 5

/datum/event/grid_check/setup()
	endWhen = rand(30,120)

/datum/event/grid_check/start()
	power_failure(0)
	var/sound/S = sound('sound/effects/powerloss.ogg')
	for(var/mob/living/M in GLOB.player_list)
		var/turf/T = get_turf(M)
		if(!M.client || !is_station_level(T.z))
			continue
		SEND_SOUND(M, S)

/datum/event/grid_check/announce()
	GLOB.event_announcement.Announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Automated Grid Check", new_sound = 'sound/AI/poweroff.ogg')

/datum/event/grid_check/end()
	power_restore()

/proc/power_failure(var/announce = 1)
	if(announce)
		GLOB.event_announcement.Announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure", new_sound = 'sound/AI/poweroff.ogg')

	var/list/skipped_areas = list(/area/turret_protected/ai)
	var/list/skipped_areas_apc = list(/area/engine/engineering)

	for(var/obj/machinery/power/smes/S in GLOB.machines)
		var/area/current_area = get_area(S)
		if((current_area.type in skipped_areas) || !is_station_level(S.z))
			continue
		S.last_charge			= S.charge
		S.last_output_attempt	= S.output_attempt
		S.last_input_attempt 	= S.input_attempt
		S.charge = 0
		S.inputting(0)
		S.outputting(0)
		S.update_icon()
		S.power_change()

	for(var/obj/machinery/power/apc/C in GLOB.apcs)
		var/area/current_area = get_area(C)
		if((current_area.type in skipped_areas_apc) || !is_station_level(C.z))
			continue
		if(C.cell)
			C.cell.charge = 0

/proc/power_restore(var/announce = 1)
	var/list/skipped_areas = list(/area/turret_protected/ai)
	var/list/skipped_areas_apc = list(/area/engine/engineering)

	if(announce)
		GLOB.event_announcement.Announce("Power has been restored to [station_name()]. We apologize for the inconvenience.", "Power Systems Nominal", new_sound = 'sound/AI/poweron.ogg')
	for(var/obj/machinery/power/apc/C in GLOB.apcs)
		var/area/current_area = get_area(C)
		if((current_area.type in skipped_areas_apc) || !is_station_level(C.z))
			continue
		if(C.cell)
			C.cell.charge = C.cell.maxcharge
	for(var/obj/machinery/power/smes/S in GLOB.machines)
		var/area/current_area = get_area(S)
		if((current_area.type in skipped_areas) || !is_station_level(S.z))
			continue
		S.charge = S.last_charge
		S.output_attempt = S.last_output_attempt
		S.input_attempt = S.last_input_attempt
		S.update_icon()
		S.power_change()

/proc/power_restore_quick(var/announce = 1)
	if(announce)
		GLOB.event_announcement.Announce("All SMESs on [station_name()] have been recharged. We apologize for the inconvenience.", "Power Systems Nominal", new_sound = 'sound/AI/poweron.ogg')
	for(var/obj/machinery/power/smes/S in GLOB.machines)
		if(!is_station_level(S.z))
			continue
		S.charge = S.capacity
		S.output_level = S.output_level_max
		S.output_attempt = 1
		S.input_attempt = 1
		S.update_icon()
		S.power_change()
