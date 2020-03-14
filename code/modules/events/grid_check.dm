#define ANNOUNCE_DELAYED FALSE
#define ANNOUNCE_NOW TRUE

#define ANNOUNCE_AFTER_MC_TICKS 5
#define APC_TOGGLE_OFF_PROBABILITY 25
#define EVENT_FIXES_ITSELF_AT_END FALSE
#define EVENT_MAX_LENGTH_MC_TICKS 150
#define EVENT_MIN_LENGTH_MC_TICKS 60

/datum/event/grid_check
	announceWhen = ANNOUNCE_AFTER_MC_TICKS

/datum/event/grid_check/setup()
	endWhen = rand(EVENT_MIN_LENGTH_MC_TICKS, EVENT_MAX_LENGTH_MC_TICKS)

/datum/event/grid_check/start()
	power_failure(ANNOUNCE_DELAYED)
	var/sound/S = sound('sound/effects/powerloss.ogg')
	for(var/mob/living/M in GLOB.player_list)
		var/turf/T = get_turf(M)
		if(!M.client || !is_station_level(T.z))
			continue
		SEND_SOUND(M, S)

/datum/event/grid_check/announce()
	event_announcement.Announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Automated Grid Check", new_sound = 'sound/AI/poweroff.ogg')

/datum/event/grid_check/end()
	if(EVENT_FIXES_ITSELF_AT_END)
		power_restore()

/proc/power_failure(var/announce = ANNOUNCE_NOW)
	var/list/skipped_areas_apc = list(
		/area/engine/engineering,
		/area/turret_protected/ai)

	if(announce)
		event_announcement.Announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure", new_sound = 'sound/AI/poweroff.ogg')

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

/proc/power_restore(var/announce = ANNOUNCE_NOW)
	var/list/skipped_areas_apc = list(
		/area/engine/engineering,
		/area/turret_protected/ai)

	if(announce)
		event_announcement.Announce("Power has been restored to [station_name()]. We apologize for the inconvenience.", "Power Systems Nominal", new_sound = 'sound/AI/poweron.ogg')

	// fix all of the APCs that the crew didn't fix
	for(var/obj/machinery/power/apc/C in GLOB.apcs)
		// skip any APCs that were too critical to flip off
		var/area/current_area = get_area(C)
		if((current_area.type in skipped_areas_apc) || !is_station_level(C.z))
			continue
		// if it was operating before the event, turn it back on
		if(C.last_operating && (C.operating == FALSE))
			C.toggle_breaker()

/proc/power_restore_quick(var/announce = ANNOUNCE_NOW)
	if(announce)
		event_announcement.Announce("All SMESs on [station_name()] have been recharged. We apologize for the inconvenience.", "Power Systems Nominal", new_sound = 'sound/AI/poweron.ogg')

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

#undef ANNOUNCE_DELAYED
#undef ANNOUNCE_NOW

#undef ANNOUNCE_AFTER_MC_TICKS
#undef APC_TOGGLE_OFF_PROBABILITY
#undef EVENT_FIXES_ITSELF_AT_END
#undef EVENT_MAX_LENGTH_MC_TICKS
#undef EVENT_MIN_LENGTH_MC_TICKS
