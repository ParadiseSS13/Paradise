
/obj/machinery/computer/station_alert
	name = "station alert console"
	desc = "Used to access the station's automated alert system."
	icon_keyboard = "tech_key"
	icon_screen = "alert:0"
	light_color = LIGHT_COLOR_CYAN
	circuit = /obj/item/circuitboard/stationalert_engineering
	var/ui_x = 325
	var/ui_y = 500
	var/alarms = list("Fire" = list(), "Atmosphere" = list(), "Power" = list())

/obj/machinery/computer/station_alert/Initialize(mapload)
	. = ..()
	GLOB.alert_consoles += src

/obj/machinery/computer/station_alert/Destroy()
	GLOB.alert_consoles -= src
	return ..()

/obj/machinery/computer/station_alert/attack_ai(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	tgui_interact(user)

/obj/machinery/computer/station_alert/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	tgui_interact(user)

/obj/machinery/computer/station_alert/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "StationAlertConsole", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/computer/station_alert/tgui_data(mob/user)
	var/list/data = list()

	data["alarms"] = list()
	for(var/class in alarms)
		data["alarms"][class] = list()
		for(var/area in alarms[class])
			data["alarms"][class] += area

	return data

/obj/machinery/computer/station_alert/proc/triggerAlarm(class, area/A, list/O, obj/alarmsource)
	if(alarmsource.z != z)
		return
	if(stat & (BROKEN))
		return

	var/list/L = alarms[class]
	for(var/I in L)
		if(I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if(!(alarmsource.UID() in sources))
				sources += alarmsource.UID()
			return TRUE
	L[A.name] = list(get_area_name(A, TRUE), O, list(alarmsource.UID()))
	update_icon()
	return TRUE


/obj/machinery/computer/station_alert/proc/cancelAlarm(class, area/A, obj/origin)
	if(stat & (BROKEN))
		return
	var/list/L = alarms[class]
	var/cleared = FALSE
	for(var/I in L)
		if(I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if(origin.UID() in srcs)
				srcs -= origin.UID()
			if(srcs.len == 0)
				cleared = TRUE
				L -= I
	update_icon()
	return !cleared

/obj/machinery/computer/station_alert/update_icon()
	var/active_alarms = FALSE
	for(var/cat in alarms)
		var/list/L = alarms[cat]
		if(L.len)
			active_alarms = TRUE
	if(active_alarms)
		icon_screen = "alert:2"
	else
		icon_screen = "alert:0"

	..()
