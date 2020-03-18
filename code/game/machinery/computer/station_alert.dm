
/obj/machinery/computer/station_alert
	name = "station alert console"
	desc = "Used to access the station's automated alert system."
	icon_keyboard = "tech_key"
	icon_screen = "alert:0"
	light_color = LIGHT_COLOR_CYAN
	circuit = /obj/item/circuitboard/stationalert_engineering
	var/datum/nano_module/alarm_monitor/alarm_monitor
	var/monitor_type = /datum/nano_module/alarm_monitor/engineering

/obj/machinery/computer/station_alert/security
	monitor_type = /datum/nano_module/alarm_monitor/security
	circuit = /obj/item/circuitboard/stationalert_security

/obj/machinery/computer/station_alert/all
	monitor_type = /datum/nano_module/alarm_monitor/all
	circuit = /obj/item/circuitboard/stationalert_all

/obj/machinery/computer/station_alert/New()
	..()
	alarm_monitor = new monitor_type(src)
	alarm_monitor.register(src, /obj/machinery/computer/station_alert/update_icon)

/obj/machinery/computer/station_alert/Destroy()
	alarm_monitor.unregister(src)
	QDEL_NULL(alarm_monitor)
	return ..()

/obj/machinery/computer/station_alert/attack_ai(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/computer/station_alert/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/computer/station_alert/interact(mob/user)
	alarm_monitor.ui_interact(user)

/obj/machinery/computer/station_alert/update_icon()
	if(alarm_monitor)
		var/list/alarms = alarm_monitor.major_alarms()
		if(alarms.len)
			icon_screen = "alert:2"
		else
			icon_screen = "alert:0"

	..()
