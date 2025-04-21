#define APC_BREAK_PROBABILITY 25 // the probability that a given APC will be disabled

/datum/event/apc_short
	var/const/announce_after_mc_ticks     = 5
	var/const/event_max_duration_mc_ticks = announce_after_mc_ticks * 2
	var/const/event_min_duration_mc_ticks = announce_after_mc_ticks

	announceWhen = announce_after_mc_ticks

/datum/event/apc_short/setup()
	endWhen = rand(event_min_duration_mc_ticks, event_max_duration_mc_ticks)

/datum/event/apc_short/start()
	power_failure(announce = FALSE)
	var/sound/S = sound('sound/effects/powerloss.ogg')
	for(var/mob/living/M in GLOB.player_list)
		var/turf/T = get_turf(M)
		if(!M.client || !is_station_level(T.z))
			continue
		SEND_SOUND(M, S)

/datum/event/apc_short/announce()
	GLOB.minor_announcement.Announce("Overload detected in [station_name()]'s powernet. Engineering, please repair shorted APCs.", "Systems Power Failure", 'sound/AI/power_short.ogg')

/datum/event/apc_short/end()
	return TRUE

/proc/depower_apcs()
	var/list/skipped_areas_apc = list(
		/area/station/engineering/engine,
		/area/station/engineering/engine/supermatter,
		/area/station/turret_protected/ai)
	GLOB.minor_announcement.Announce("Power failure detected in [station_name()]'s powernet. All APCs have lost power. Gravity systems likely to fail.", "Systems Power Failure", 'sound/AI/attention.ogg')
	for(var/thing in GLOB.apcs)
		var/obj/machinery/power/apc/A = thing
		var/area/current_area = get_area(A)
		if((current_area.type in skipped_areas_apc) || !is_station_level(A.z))
			continue
		var/obj/item/stock_parts/cell/C = A.get_cell()
		if(C)
			C.charge = 0
		current_area.powernet.power_change()
	log_and_message_admins("Power has been drained from all APCs.")

/proc/power_failure(announce = TRUE, probability = APC_BREAK_PROBABILITY)
	// skip any APCs that are too critical to disable
	var/list/skipped_areas_apc = list(
		/area/station/engineering/engine,
		/area/station/engineering/engine/supermatter,
		/area/station/turret_protected/ai)
	if(announce)
		GLOB.minor_announcement.Announce("Overload detected in [station_name()]'s powernet. Engineering, please repair shorted APCs.", "Systems Power Failure", 'sound/AI/power_short.ogg')
	// break APC_BREAK_PROBABILITY% of all of the APCs on the station
	var/affected_apc_count = 0
	for(var/thing in GLOB.apcs)
		var/obj/machinery/power/apc/A = thing
		var/area/current_area = get_area(A)
		if((current_area.type in skipped_areas_apc) || !is_station_level(A.z))
			continue
		// if we are going to break this one
		if(prob(probability))
			A.apc_short()
			affected_apc_count++
	log_and_message_admins("APC Short Out event has shorted out [affected_apc_count] APCs.")

/proc/power_restore(announce = TRUE, power_type)
	if(power_type == 0)	//Power without Repairing
		if(announce)
			GLOB.minor_announcement.Announce("All operational APCs on \the [station_name()] have been fully charged.", "Power Systems Nominal", 'sound/AI/power_restore.ogg')
		var/affected_apc_count = 0
		for(var/thing in GLOB.apcs)
			var/obj/machinery/power/apc/A = thing
			var/area/current_area = get_area(A)
			if(!is_station_level(A.z))
				continue
			if(!length(A.wires.cut_wires) && A.operating && !A.shorted)
				A.recharge_apc()
			affected_apc_count++
			current_area.powernet.power_change()
		log_and_message_admins("Power has been restored to [affected_apc_count] APCs.")
	if(power_type == 1)	//Repair without charging
		if(announce)
			GLOB.minor_announcement.Announce("All APCs on \the [station_name()] have been repaired.", "Power Systems Nominal", 'sound/AI/power_restore.ogg')
		for(var/thing in GLOB.apcs)
			var/obj/machinery/power/apc/A = thing
			var/area/current_area = get_area(A)
			if(!is_station_level(A.z))
				continue
			A.repair_apc()
			current_area.powernet.power_change()
		log_and_message_admins("Power has been restored to all APCs.")
	if(power_type == 2)	//Repair and Power APCs
		if(announce)
			GLOB.minor_announcement.Announce("All APCs on \the [station_name()] have been repaired and recharged. We apologize for the inconvenience.", "Power Systems Optimal", 'sound/AI/power_restore.ogg')
		// repair the APCs and recharge them
		for(var/thing in GLOB.apcs)
			var/obj/machinery/power/apc/A = thing
			var/area/current_area = get_area(A)
			if(!is_station_level(A.z))
				continue
			A.repair_apc()
			A.recharge_apc()
			current_area.powernet.power_change()
		log_and_message_admins("Power has been restored to all APCs.")

/proc/power_restore_quick(announce = TRUE)
	if(announce)
		GLOB.minor_announcement.Announce("All SMESs on \the [station_name()] have been recharged. We apologize for the inconvenience.", "Power Systems Nominal", 'sound/AI/power_restore.ogg')
	// fix all of the SMESs
	for(var/obj/machinery/power/smes/S in SSmachines.get_by_type(/obj/machinery/power/smes))
		if(!is_station_level(S.z))
			continue
		S.charge = S.capacity
		S.output_level = S.output_level_max
		S.output_attempt = 1
		S.input_attempt = 1
		S.update_icon()
		S.power_change()

#undef APC_BREAK_PROBABILITY
