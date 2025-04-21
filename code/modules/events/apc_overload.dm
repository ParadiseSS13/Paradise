#define APC_BREAK_PROBABILITY 25 // the probability that a given APC will be broken

/datum/event/apc_overload
	var/const/announce_after_mc_ticks     = 5
	var/const/delayed                     = FALSE
	var/const/event_max_duration_mc_ticks = announce_after_mc_ticks * 2
	var/const/event_min_duration_mc_ticks = announce_after_mc_ticks

	announceWhen = announce_after_mc_ticks

/datum/event/apc_overload/setup()
	endWhen = rand(event_min_duration_mc_ticks, event_max_duration_mc_ticks)

/datum/event/apc_overload/start()
	apc_overload_failure(announce=delayed)
	var/sound/S = sound('sound/effects/powerloss.ogg')
	for(var/mob/living/M in GLOB.player_list)
		var/turf/T = get_turf(M)
		if(!M.client || !is_station_level(T.z))
			continue
		SEND_SOUND(M, S)

/datum/event/apc_overload/announce()
	GLOB.minor_announcement.Announce("Зафиксирована перегрузка энергосети станции [station_name()]. Инженерному отделу надлежит проверить все терминалы ЛКП под напольным покрытием.", "ВНИМАНИЕ: Критический сбой системы питания.", 'sound/AI/power_overload.ogg')

/datum/event/apc_overload/end()
	return TRUE

/proc/apc_overload_failure(announce=TRUE)
	var/list/skipped_areas_apc = list(
		/area/station/engineering/engine,
		/area/station/engineering/engine/supermatter,
		/area/station/turret_protected/ai)

	if(announce)
		GLOB.minor_announcement.Announce("Зафиксирована перегрузка энергосети станции [station_name()]. Инженерному отделу надлежит проверить все терминалы ЛКП под напольным покрытием.", "ВНИМАНИЕ: Критический сбой системы питания.", 'sound/AI/power_overload.ogg')

	// break APC_BREAK_PROBABILITY% of all of the APCs on the station
	var/affected_apc_count = 0
	for(var/thing in GLOB.apcs)
		var/obj/machinery/power/apc/C = thing
		// skip any APCs that are too critical to break
		var/area/current_area = get_area(C)
		if((current_area.type in skipped_areas_apc) || !is_station_level(C.z))
			continue
		// if we are going to break this one
		if(prob(APC_BREAK_PROBABILITY))
			// if it has a cell, drain all the charge from the cell
			if(C.cell)
				C.cell.charge = 0
			// if it has a terminal, disconnect and delete the terminal
			if(C.terminal)
				var/obj/machinery/power/terminal/T = C.terminal
				C.terminal.master = null
				C.terminal = null
				qdel(T)
			// if it was operating, toggle off the breaker
			if(C.operating)
				C.toggle_breaker()
			// no matter what, ensure the area knows something happened to the power
			current_area.powernet.power_change()
			affected_apc_count++
	log_and_message_admins("APC Overload event deleted [affected_apc_count] underfloor APC terminals.")

#undef APC_BREAK_PROBABILITY
