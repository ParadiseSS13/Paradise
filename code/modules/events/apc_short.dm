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
	GLOB.minor_announcement.Announce("Зафиксирована перегрузка энергосети станции [station_name()]. Инженерному отделу надлежит проверить все замкнувшие ЛКП.", "ВНИМАНИЕ: Сбой системы питания.", 'sound/AI/power_short.ogg')

/datum/event/apc_short/end()
	return TRUE

/proc/depower_apcs()
	var/list/skipped_areas_apc = list(
		/area/station/engineering/engine,
		/area/station/engineering/engine/supermatter,
		/area/station/turret_protected/ai)
	GLOB.minor_announcement.Announce("Обнаружен сбой питания в сети [station_name()]. Все ЛКП были разряжены. Вероятен отказ генератора гравитации.", "ВНИМАНИЕ: Отказ системы питания.", 'sound/AI/attention.ogg')
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

/proc/power_failure(announce = TRUE)
	// skip any APCs that are too critical to disable
	var/list/skipped_areas_apc = list(
		/area/station/engineering/engine,
		/area/station/engineering/engine/supermatter,
		/area/station/turret_protected/ai)
	if(announce)
		GLOB.minor_announcement.Announce("Зафиксирована перегрузка энергосети станции [station_name()]. Инженерному отделу надлежит проверить все замкнувшие ЛКП.", "ВНИМАНИЕ: Сбой системы питания.", 'sound/AI/power_short.ogg')
	// break APC_BREAK_PROBABILITY% of all of the APCs on the station
	var/affected_apc_count = 0
	for(var/thing in GLOB.apcs)
		var/obj/machinery/power/apc/A = thing
		var/area/current_area = get_area(A)
		if((current_area.type in skipped_areas_apc) || !is_station_level(A.z))
			continue
		// if we are going to break this one
		if(prob(APC_BREAK_PROBABILITY))
			A.apc_short()
			affected_apc_count++
	log_and_message_admins("APC Short Out event has shorted out [affected_apc_count] APCs.")

/proc/power_restore(announce = TRUE, power_type)
	if(power_type == 0)	//Power without Repairing
		if(announce)
			GLOB.minor_announcement.Announce("Все исправные ЛКП на \the [station_name()] были успешно заряжены", "Системы электропитания.", 'sound/AI/power_restore.ogg')
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
			GLOB.minor_announcement.Announce("Все ЛКП на \the [station_name()] были восстановлены.", "Системы электропитания.", 'sound/AI/power_restore.ogg')
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
			GLOB.minor_announcement.Announce("Все ЛКП на \the [station_name()] были восстановлены и заряжены. Приносим извенения за неудобства.", "Системы электропитания.", 'sound/AI/power_restore.ogg')
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
		GLOB.minor_announcement.Announce("Все СМЕСы на \the [station_name()] были заряжены. Приносим извенения за неудобства.", "Системы электропитания.", 'sound/AI/power_restore.ogg')
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

#undef APC_BREAK_PROBABILITY
