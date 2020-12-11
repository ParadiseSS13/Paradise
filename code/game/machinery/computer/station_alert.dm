
/obj/machinery/computer/station_alert
	name = "station alert console"
	desc = "Used to access the station's automated alert system."
	icon_keyboard = "tech_key"
	icon_screen = "alert:0"
	light_color = LIGHT_COLOR_CYAN
	circuit = /obj/item/circuitboard/stationalert_engineering
	var/ui_x = 325
	var/ui_y = 500
	var/list/alarms_listend_for = list("Fire", "Atmosphere", "Power")

/obj/machinery/computer/station_alert/Initialize(mapload)
	. = ..()
	GLOB.alert_consoles += src
	RegisterSignal(SSalarm, COMSIG_TRIGGERED_ALARM, .proc/alarm_triggered)
	RegisterSignal(SSalarm, COMSIG_CANCELLED_ALARM, .proc/alarm_cancelled)

/obj/machinery/computer/station_alert/Destroy()
	GLOB.alert_consoles -= src
	return ..()

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

/obj/machinery/computer/station_alert/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "StationAlertConsole", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/computer/station_alert/ui_data(mob/user)
	var/list/data = list()

	data["alarms"] = list()
	for(var/class in SSalarm.alarms)
		if(!(class in alarms_listend_for))
			continue
		data["alarms"][class] = list()
		for(var/area in SSalarm.alarms[class])
			for(var/thing in SSalarm.alarms[class][area][3])
				var/atom/A = locateUID(thing)
				if(atoms_share_level(A, src))
					data["alarms"][class] += area

	return data

/obj/machinery/computer/station_alert/proc/alarm_triggered(src, class, area/A, list/O, obj/alarmsource)
	if(!(class in alarms_listend_for))
		return
	if(alarmsource.z != z)
		return
	if(stat & (BROKEN))
		return
	update_icon()

/obj/machinery/computer/station_alert/proc/alarm_cancelled(src, class, area/A, obj/origin, cleared)
	if(!(class in alarms_listend_for))
		return
	if(origin.z != z)
		return
	if(stat & (BROKEN))
		return
	update_icon()

/obj/machinery/computer/station_alert/update_icon()
	var/active_alarms = FALSE
	var/list/list/temp_alarm_list = SSalarm.alarms.Copy()
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

	..()
