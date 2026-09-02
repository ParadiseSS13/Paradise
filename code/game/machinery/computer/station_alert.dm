
/obj/machinery/computer/station_alert
	name = "station alert console"
	desc = "Used to access the station's automated alert system."
	icon_keyboard = "tech_key"
	icon_screen = "alert:0"
	light_color = LIGHT_COLOR_CYAN
	circuit = /obj/item/circuitboard/stationalert_engineering
	var/list/alarms_listend_for = list("Fire", "Atmosphere", "Power")
	var/parent_area_type
	var/list/areas = list()

/obj/machinery/computer/station_alert/Initialize(mapload)
	. = ..()
	RegisterSignal(GLOB.alarm_manager, COMSIG_TRIGGERED_ALARM, PROC_REF(alarm_triggered))
	RegisterSignal(GLOB.alarm_manager, COMSIG_CANCELLED_ALARM, PROC_REF(alarm_cancelled))

	var/area/machine_area = get_area(src)
	parent_area_type = machine_area.get_top_parent_type()
	if(parent_area_type)
		areas = typesof(parent_area_type)


/obj/machinery/computer/station_alert/attack_ai(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/station_alert/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/station_alert/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/station_alert/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StationAlertConsole", name)
		ui.open()

/obj/machinery/computer/station_alert/ui_data(mob/user)
	var/list/data = list()

	data["alarms"] = list()
	for(var/class in GLOB.alarm_manager.alarms)
		if(!(class in alarms_listend_for))
			continue
		data["alarms"][class] = list()
		for(var/area in GLOB.alarm_manager.alarms[class])
			for(var/thing in GLOB.alarm_manager.alarms[class][area][3])
				var/atom/A = locateUID(thing)
				if(A && ((get_area(A)).type in areas) && A.z == z)
					data["alarms"][class] += area

	return data

/obj/machinery/computer/station_alert/proc/alarm_triggered(source, class, area/A, list/O, obj/alarmsource)
	if(!(class in alarms_listend_for))
		return
	if(alarmsource.z != z)
		return
	if(stat & (BROKEN))
		return
	update_icon()

/obj/machinery/computer/station_alert/proc/alarm_cancelled(source, class, area/A, obj/origin, cleared)
	if(!(class in alarms_listend_for))
		return
	if(origin.z != z)
		return
	if(stat & (BROKEN))
		return
	update_icon()

/obj/machinery/computer/station_alert/update_icon_state()
	var/active_alarms = FALSE
	var/list/list/temp_alarm_list = GLOB.alarm_manager.alarms.Copy()
	for(var/cat in temp_alarm_list)
		if(!(cat in alarms_listend_for))
			continue
		var/list/list/L = temp_alarm_list[cat].Copy()
		for(var/alarm in L)
			var/list/list/alm = L[alarm].Copy()
			var/list/list/sources = alm[3].Copy()
			for(var/thing in sources)
				var/atom/A = locateUID(thing)
				if(A && A.z != z)
					L -= alarm
		if(length(L))
			active_alarms = TRUE
	if(active_alarms)
		icon_screen = "alert:2"
	else
		icon_screen = "alert:0"
