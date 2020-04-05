SUBSYSTEM_DEF(alarms)
	name = "Alarms"
	init_order = INIT_ORDER_ALARMS // 2
	var/datum/alarm_handler/atmosphere/atmosphere_alarm = new()
	var/datum/alarm_handler/burglar/burglar_alarm = new()
	var/datum/alarm_handler/camera/camera_alarm = new()
	var/datum/alarm_handler/fire/fire_alarm = new()
	var/datum/alarm_handler/motion/motion_alarm = new()
	var/datum/alarm_handler/power/power_alarm = new()
	var/list/datum/alarm/all_handlers

/datum/controller/subsystem/alarms/Initialize(start_timeofday)
	all_handlers = list(SSalarms.atmosphere_alarm, SSalarms.burglar_alarm, SSalarms.camera_alarm, SSalarms.fire_alarm, SSalarms.motion_alarm, SSalarms.power_alarm)
	return ..()

/datum/controller/subsystem/alarms/fire()
	for(var/datum/alarm_handler/AH in all_handlers)
		AH.process()

/datum/controller/subsystem/alarms/proc/active_alarms()
	var/list/all_alarms = new ()
	for(var/datum/alarm_handler/AH in all_handlers)
		var/list/alarms = AH.alarms
		all_alarms += alarms

	return all_alarms

/datum/controller/subsystem/alarms/proc/number_of_active_alarms()
	var/list/alarms = active_alarms()
	return alarms.len
