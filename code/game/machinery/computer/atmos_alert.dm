/obj/machinery/computer/atmos_alert
	name = "atmospheric alert computer"
	desc = "Used to access the station's atmospheric sensors."
	circuit = /obj/item/circuitboard/atmos_alert
	icon_keyboard = "atmos_key"
	icon_screen = "alert:0"
	light_color = LIGHT_COLOR_CYAN
	// List of alarms and their state in areas. This is sent to TGUI
	var/list/alarm_cache
	var/parent_area_type

/obj/machinery/computer/atmos_alert/Initialize(mapload)
	. = ..()
	alarm_cache = list()
	alarm_cache["priority"] = list()
	alarm_cache["minor"] = list()
	alarm_cache["mode"] = list()
	var/area/machine_area = get_area(src)
	parent_area_type = machine_area.get_top_parent_type()

/obj/machinery/computer/atmos_alert/process()
	alarm_cache = list()
	alarm_cache["priority"] = list()
	alarm_cache["minor"] = list()
	alarm_cache["mode"] = list()
	for(var/area/A in GLOB.all_areas)
		if(!istype(A, parent_area_type))
			continue
		var/alarm_level = null
		for(var/obj/machinery/alarm/air_alarm in A.air_alarms)
			if(!istype(air_alarm))
				continue
			if(!air_alarm.report_danger_level)
				continue
			switch(air_alarm.alarm_area.atmosalm)
				if(ATMOS_ALARM_DANGER)
					alarm_level = "priority"
				if(ATMOS_ALARM_WARNING)
					if(isnull(alarm_level))
						alarm_level = "minor"
			if(!isnull(alarm_level))
				alarm_cache[alarm_level] += A.name
			if(air_alarm.mode != AALARM_MODE_FILTERING)
				alarm_cache["mode"][A.name] = GLOB.aalarm_modes["[air_alarm.mode]"]

	update_icon()

/obj/machinery/computer/atmos_alert/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/computer/atmos_alert/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/atmos_alert/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosAlertConsole", name)
		ui.open()

/obj/machinery/computer/atmos_alert/ui_data(mob/user)
	return alarm_cache

/obj/machinery/computer/atmos_alert/update_icon_state()
	if(!length(alarm_cache)) // This happens if were mid init
		icon_screen = "alert:0"
		return ..()


	if(length(alarm_cache["priority"]))
		icon_screen = "alert:2"
	else if(length(alarm_cache["minor"]))
		icon_screen = "alert:1"
	else
		icon_screen = "alert:0"
	..()
