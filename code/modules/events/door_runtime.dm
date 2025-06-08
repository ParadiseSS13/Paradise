/datum/event/door_runtime

/datum/event/door_runtime/announce()
	GLOB.minor_announcement.Announce("Вредоносное программное обеспечение обнаружено в системе контроля шлюзов. Задействованы протоколы изоляции. Пожалуйста, сохраняйте спокойствие.", "ВНИМАНИЕ: Уязвимость сети.", 'sound/AI/door_runtimes.ogg')

/datum/event/door_runtime/start()
	for(var/obj/machinery/door/D in GLOB.airlocks)
		if(!is_station_level(D.z))
			continue
		INVOKE_ASYNC(D, TYPE_PROC_REF(/obj/machinery/door, hostile_lockdown))
		addtimer(CALLBACK(D, TYPE_PROC_REF(/obj/machinery/door, disable_lockdown)), 90 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(reboot)), 90 SECONDS)
	post_status(STATUS_DISPLAY_ALERT, "lockdown")

/datum/event/door_runtime/proc/reboot()
	GLOB.minor_announcement.Announce("Автоматическая перезагрузка системы завершена. Хорошего вам дня.","ПЕРЕЗАГРУЗКА СЕТИ:", 'sound/AI/door_runtimes_fix.ogg')
