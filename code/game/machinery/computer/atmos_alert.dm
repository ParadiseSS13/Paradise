/obj/machinery/computer/atmos_alert
	name = "atmospheric alert computer"
	desc = "Used to access the station's atmospheric sensors."
	circuit = /obj/item/circuitboard/atmos_alert
	icon_keyboard = "atmos_key"
	icon_screen = "alert:0"
	light_color = LIGHT_COLOR_CYAN
	// List of alarms and their state in areas. This is sent to TGUI
	var/list/alarm_cache

/obj/machinery/computer/atmos_alert/Initialize(mapload)
	. = ..()
	alarm_cache = list()
	alarm_cache["minor"] = list()
	alarm_cache["priority"] = list()

/obj/machinery/computer/atmos_alert/process()
	// This is relatively cheap because the areas list is pretty small
	for(var/area/A as anything in GLOB.all_areas)
		if(!A.master_air_alarm)
			continue // No alarm
		if(A.master_air_alarm.z != z)
			continue // Not on our z-level
		if(!A.master_air_alarm.report_danger_level)
			continue

		switch(A.atmosalm)
			if(ATMOS_ALARM_DANGER)
				alarm_cache["priority"] |= A.name
				alarm_cache["minor"] -= A.name
			if(ATMOS_ALARM_WARNING)
				alarm_cache["priority"] -= A.name
				alarm_cache["minor"] |= A.name
			else
				alarm_cache["priority"] -= A.name
				alarm_cache["minor"] -= A.name

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
