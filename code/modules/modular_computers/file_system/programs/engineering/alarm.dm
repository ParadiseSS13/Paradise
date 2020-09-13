/datum/computer_file/program/alarm_monitor
	filename = "alarmmonitor"
	filedesc = "Alarm Monitoring"
	ui_header = "alarm_green.gif"
	program_icon_state = "alert-green"
	extended_desc = "This program provides visual interface for station's alarm system."
	requires_ntnet = 1
	network_destination = "alarm monitoring network"
	size = 5
	var/tgui_id = "NtosStationAlertConsole"
	var/ui_x = 315
	var/ui_y = 500
	var/has_alert = 0
	var/list/alarms_listend_for = list("Fire", "Atmosphere", "Power")

/datum/computer_file/program/alarm_monitor/process_tick()
	..()

	if(has_alert)
		program_icon_state = "alert-red"
		ui_header = "alarm_red.gif"
		update_computer_icon()
	else
		program_icon_state = "alert-green"
		ui_header = "alarm_green.gif"
		update_computer_icon()
	return TRUE

/datum/computer_file/program/alarm_monitor/tgui_data(mob/user)
	var/list/data = get_header_data()

	data["alarms"] = list()
	for(var/class in SSalarm.alarms)
		if(!(class in alarms_listend_for))
			continue
		data["alarms"][class] = list()
		for(var/area in alarms[class])
			data["alarms"][class] += area

	return data

/datum/computer_file/program/alarm_monitor/proc/alarm_triggered(src, class, area/A, list/O, obj/alarmsource)
	if(is_station_level(alarmsource.z))
		if(!(A.type in GLOB.the_station_areas))
			return
	else if(!is_mining_level(alarmsource.z) || istype(A, /area/ruin))
		return
	update_alarm_display()

/datum/computer_file/program/alarm_monitor/proc/alarm_cancelled(src, class, area/A, obj/origin, cleared)
	if(is_station_level(origin.z))
		if(!(A.type in GLOB.the_station_areas))
			return
	else if(!is_mining_level(origin.z) || istype(A, /area/ruin))
		return
	update_alarm_display()

/datum/computer_file/program/alarm_monitor/proc/update_alarm_display()
	has_alert = FALSE
	for(var/cat in alarms)
		if(!(cat in alarms_listend_for))
			continue
		var/list/L = alarms[cat]
		if(length(L))
			has_alert = TRUE

/datum/computer_file/program/alarm_monitor/run_program(mob/user)
	. = ..(user)
	GLOB.alarmdisplay += src
	RegisterSignal(SSalarm, COMSIG_TRIGGERED_ALARM, .proc/alarm_triggered)
	RegisterSignal(SSalarm, COMSIG_CANCELLED_ALARM, .proc/alarm_cancelled)

/datum/computer_file/program/alarm_monitor/kill_program(forced = FALSE)
	GLOB.alarmdisplay -= src
	UnregisterSignal(SSalarm, COMSIG_TRIGGERED_ALARM)
	UnregisterSignal(SSalarm, COMSIG_CANCELLED_ALARM)
	..()
