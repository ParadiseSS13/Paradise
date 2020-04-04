#define APC_DISABLE_PROBABILITY 25 // the probability that a given APC will be disabled

/datum/event/grid_check
	var/const/announce_after_mc_ticks     = 5
	var/const/delayed                     = FALSE
	var/const/event_max_duration_mc_ticks = announce_after_mc_ticks * 2
	var/const/event_min_duration_mc_ticks = announce_after_mc_ticks

	announceWhen = announce_after_mc_ticks

/datum/event/grid_check/setup()
	endWhen = rand(event_min_duration_mc_ticks, event_max_duration_mc_ticks)

/datum/event/grid_check/start()
	power_failure(announce=delayed)
	var/sound/S = sound('sound/effects/powerloss.ogg')
	for(var/mob/living/M in GLOB.player_list)
		var/turf/T = get_turf(M)
		if(!M.client || !is_station_level(T.z))
			continue
		SEND_SOUND(M, S)

/datum/event/grid_check/announce()
	GLOB.event_announcement.Announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Systems Power Failure", new_sound = 'sound/AI/poweroff.ogg')

/datum/event/grid_check/end()
	return TRUE

/proc/power_failure(announce=TRUE)
	var/list/skipped_areas_apc = list(
		/area/engine/engineering,
		/area/turret_protected/ai)

	if(announce)
		GLOB.event_announcement.Announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Systems Power Failure", new_sound = 'sound/AI/poweroff.ogg')

	// break APC_DISABLE_PROBABILITY% of all of the APCs on the station
	var/affected_apc_count = 0
	for(var/obj/machinery/power/apc/C in GLOB.apcs)
		// skip any APCs that are too critical to disable
		var/area/current_area = get_area(C)
		if((current_area.type in skipped_areas_apc) || !is_station_level(C.z))
			continue
		// if we are going to break this one
		if(prob(APC_DISABLE_PROBABILITY))
			// if it has internal wires, cut the power wires
			if(C.wires)
				if(!C.wires.IsIndexCut(APC_WIRE_MAIN_POWER1))
					C.wires.CutWireIndex(APC_WIRE_MAIN_POWER1)
				if(!C.wires.IsIndexCut(APC_WIRE_MAIN_POWER2))
					C.wires.CutWireIndex(APC_WIRE_MAIN_POWER2)
			// if it was operating, toggle off the breaker
			if(C.operating)
				C.toggle_breaker()
			// no matter what, ensure the area knows something happened to the power
			current_area.power_change()
			affected_apc_count++
	message_admins("Systems Power Failure event disabled [affected_apc_count] APCs.")

/proc/power_restore(announce=TRUE)
	power_restore_quick(announce)

/proc/power_restore_quick(announce=TRUE)
	if(announce)
		GLOB.event_announcement.Announce("All SMESs on [station_name()] have been recharged. We apologize for the inconvenience.", "Power Systems Nominal", new_sound = 'sound/AI/poweron.ogg')

	// fix all of the SMESs
	for(var/obj/machinery/power/smes/S in GLOB.machines)
		if(!is_station_level(S.z))
			continue
		S.charge = S.capacity
		S.output_level = S.output_level_max
		S.output_attempt = 1
		S.input_attempt = 1
		S.update_icon()
		S.power_change()

#undef APC_DISABLE_PROBABILITY
