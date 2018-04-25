var/global/list/priority_air_alarms = list()
var/global/list/minor_air_alarms = list()


/obj/machinery/computer/atmos_alert
	name = "atmospheric alert computer"
	desc = "Used to access the station's atmospheric sensors."
	circuit = /obj/item/circuitboard/atmos_alert
	icon_keyboard = "atmos_key"
	icon_screen = "alert:0"
	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/atmos_alert/New()
	..()
	atmosphere_alarm.register(src, /obj/machinery/computer/station_alert/update_icon)

/obj/machinery/computer/atmos_alert/Destroy()
    atmosphere_alarm.unregister(src)
    return ..()

/obj/machinery/computer/atmos_alert/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/computer/atmos_alert/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "atmos_alert.tmpl", src.name, 500, 500)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/atmos_alert/ui_data(mob/user, datum/topic_state/state)
	var/data[0]
	var/major_alarms[0]
	var/minor_alarms[0]

	for(var/datum/alarm/alarm in atmosphere_alarm.major_alarms())
		major_alarms[++major_alarms.len] = list("name" = sanitize(alarm.alarm_name()), "ref" = "\ref[alarm]")

	for(var/datum/alarm/alarm in atmosphere_alarm.minor_alarms())
		minor_alarms[++minor_alarms.len] = list("name" = sanitize(alarm.alarm_name()), "ref" = "\ref[alarm]")

	data["priority_alarms"] = major_alarms
	data["minor_alarms"] = minor_alarms

	return data

/obj/machinery/computer/atmos_alert/update_icon()
	var/list/alarms = atmosphere_alarm.major_alarms()
	if(alarms.len)
		icon_screen = "alert:2"
	else
		alarms = atmosphere_alarm.minor_alarms()
		if(alarms.len)
			icon_screen = "alert:1"
		else
			icon_screen = "alert:0"
	..()

/obj/machinery/computer/atmos_alert/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["clear_alarm"])
		var/datum/alarm/alarm = locate(href_list["clear_alarm"]) in atmosphere_alarm.alarms
		if(alarm)
			for(var/datum/alarm_source/alarm_source in alarm.sources)
				var/obj/machinery/alarm/air_alarm = alarm_source.source
				if(istype(air_alarm))
					var/list/new_ref = list("atmos_reset" = 1)
					air_alarm.Topic(href, new_ref, state = air_alarm_topic)
					update_icon()
		return 1


var/datum/topic_state/air_alarm_topic/air_alarm_topic = new()

/datum/topic_state/air_alarm_topic/href_list(var/mob/user)
	var/list/extra_href = list()
	extra_href["remote_connection"] = 1
	extra_href["remote_access"] = 1

	return extra_href

/datum/topic_state/air_alarm_topic/can_use_topic(var/src_object, var/mob/user)
	return STATUS_INTERACTIVE
