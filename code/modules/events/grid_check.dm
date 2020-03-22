#define APC_TOGGLE_OFF_PROBABILITY 25 // the percent chance for each APC to toggle off when the event starts
#define APC_TOGGLE_ON_PROBABILITY 100 // the percent chance for each APC to toggle back on when the event ends

/datum/event/grid_check
	var/const/announce_after_mc_ticks		= 5
	var/const/delayed						= FALSE
	var/const/event_fixes_itself_at_end		= FALSE	// APCs do NOT get fixed when the event ends!
	var/const/event_max_duration_mc_ticks	= 150
	var/const/event_min_duration_mc_ticks	= 60

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
	GLOB.event_announcement.Announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Automated Grid Check", new_sound = 'sound/AI/poweroff.ogg')

/datum/event/grid_check/end()
	if(event_fixes_itself_at_end)
		power_restore()

/proc/power_failure(announce=TRUE)
	var/list/skipped_areas_apc = list(
		/area/engine/engineering,
		/area/turret_protected/ai)

	if(announce)
		GLOB.event_announcement.Announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure", new_sound = 'sound/AI/poweroff.ogg')

	// break APC_TOGGLE_OFF_PROBABILITY% of all of the APCs on the station
	for(var/obj/machinery/power/apc/C in GLOB.apcs)
		// skip any APCs that are too critical to flip off
		var/area/current_area = get_area(C)
		if((current_area.type in skipped_areas_apc) || !is_station_level(C.z))
			continue
		// otherwise, make a note to remember if we need to turn it back on
		C.last_operating = C.operating
		if(prob(APC_TOGGLE_OFF_PROBABILITY) && (C.operating))
			C.toggle_breaker()

/proc/power_restore(announce=TRUE)
	var/list/skipped_areas_apc = list(
		/area/engine/engineering,
		/area/turret_protected/ai)

	if(announce)
		GLOB.event_announcement.Announce("Power has been restored to [station_name()]. We apologize for the inconvenience.", "Power Systems Nominal", new_sound = 'sound/AI/poweron.ogg')

	// fix APC_TOGGLE_ON_PROBABILITY% of all of the APCs that the crew didn't fix
	for(var/obj/machinery/power/apc/C in GLOB.apcs)
		// skip any APCs that were too critical to flip off
		var/area/current_area = get_area(C)
		if((current_area.type in skipped_areas_apc) || !is_station_level(C.z))
			continue
		// if it was operating before the event, turn it back on
		if(prob(APC_TOGGLE_ON_PROBABILITY) && C.last_operating && (C.operating == FALSE))
			C.toggle_breaker()

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

#undef APC_TOGGLE_OFF_PROBABILITY
#undef APC_TOGGLE_ON_PROBABILITY
