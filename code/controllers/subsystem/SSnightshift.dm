SUBSYSTEM_DEF(nightshift)
	name = "Night Shift"
	init_order = INIT_ORDER_NIGHTSHIFT
	priority = FIRE_PRIORITY_NIGHTSHIFT
	wait = 600
	flags = SS_NO_TICK_CHECK
	offline_implications = "The game will no longer shift between day and night lighting. No immediate action is needed."
	cpu_display = SS_CPUDISPLAY_LOW

	var/nightshift_active = FALSE
	var/nightshift_start_time = 702000		//7:30 PM, station time
	var/nightshift_end_time = 270000		//7:30 AM, station time
	var/nightshift_first_check = 30 SECONDS

	var/high_security_mode = FALSE

/datum/controller/subsystem/nightshift/Initialize()
	if(!GLOB.configuration.general.enable_night_shifts)
		flags |= SS_NO_FIRE
	if(GLOB.configuration.general.randomise_shift_time)
		GLOB.gametime_offset = rand(0, 23) HOURS

/datum/controller/subsystem/nightshift/fire(resumed = FALSE)
	if(world.time - SSticker.round_start_time < nightshift_first_check)
		return
	check_nightshift()

/datum/controller/subsystem/nightshift/proc/announce(message)
	GLOB.minor_announcement.Announce(message, new_sound = 'sound/misc/notice2.ogg', new_title = "Система освещения.")

/datum/controller/subsystem/nightshift/proc/check_nightshift(check_canfire=FALSE)
	if(check_canfire && !can_fire)
		return
	var/emergency = SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED
	var/announcing = TRUE
	var/time = station_time()
	var/night_time = (time < nightshift_end_time) || (time > nightshift_start_time)
	if(high_security_mode != emergency)
		high_security_mode = emergency
		if(night_time)
			announcing = FALSE
			if(!emergency)
				announce("Система ночного освещения снова работает в штатном режиме.")
			else
				announce("Система ночного освещения отключена в связи с наличием существенной угрозы для станции. Пожалуйста, сохраняйте спокойствие.")
	if(emergency)
		night_time = FALSE
	if(nightshift_active != night_time)
		update_nightshift(night_time, announcing)

/datum/controller/subsystem/nightshift/proc/update_nightshift(active, announce = TRUE)
	nightshift_active = active
	if(announce)
		if(active)
			announce("Добрый вечер, экипаж. Для снижения энергопотребления и стимуляции циркадных ритмов некоторых видов, освещение на борту станции переведено в ночной режим.")
		else
			announce("Доброе утро, экипаж. В связи с наступлением дневного времени освещение на борту станции переведено в дневной режим.")
	for(var/A in GLOB.apcs)
		var/obj/machinery/power/apc/APC = A
		if(is_station_level(APC.z))
			APC.set_nightshift(active)
