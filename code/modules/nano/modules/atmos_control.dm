/datum/nano_module/atmos_control
	name = "Atmospherics Control"
	var/obj/access = new()
	var/emagged = 0
	var/ui_ref
	var/list/monitored_alarms = null

/datum/nano_module/atmos_control/New(atmos_computer, req_access, req_one_access, monitored_alarm_ids)
	..()
	access.req_access = req_access
	access.req_one_access = req_one_access

	if(monitored_alarm_ids)
		for(var/obj/machinery/alarm/alarm in GLOB.machines)
			if(alarm.alarm_id && alarm.alarm_id in monitored_alarm_ids)
				monitored_alarms += alarm
		// machines may not yet be ordered at this point
		monitored_alarms = dd_sortedObjectList(monitored_alarms)

/datum/nano_module/atmos_control/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["alarm"])
		if(ui_ref)
			var/obj/machinery/alarm/alarm = locate(href_list["alarm"]) in (monitored_alarms ? monitored_alarms : GLOB.machines)
			if(alarm)
				var/datum/topic_state/air_alarm/TS = generate_state(alarm)
				alarm.ui_interact(usr, master_ui = ui_ref, state = TS)

/datum/nano_module/atmos_control/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/master_ui = null, var/datum/topic_state/state = default_state)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "atmos_control.tmpl", src.name, 900, 800, state = state)
		ui.add_template("mapContent", "atmos_control_map_content.tmpl")
		ui.add_template("mapHeader", "atmos_control_map_header.tmpl")
		ui.set_show_map(1)
		ui.open()
		ui.set_auto_update(1)
	ui_ref = ui

/datum/nano_module/atmos_control/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	data["alarms"] = air_alarm_repository.air_alarm_data(monitored_alarms)

	return data

/datum/nano_module/atmos_control/proc/generate_state(air_alarm)
	var/datum/topic_state/air_alarm/state = new()
	state.atmos_control = src
	state.air_alarm = air_alarm
	return state

/datum/topic_state/air_alarm
	var/datum/nano_module/atmos_control/atmos_control	= null
	var/obj/machinery/alarm/air_alarm					= null

/datum/topic_state/air_alarm/can_use_topic(var/src_object, var/mob/user)
	if(!isAI(user) && !in_range(atmos_control.nano_host(), user))
		return STATUS_CLOSE
	if(has_access(user))
		return STATUS_INTERACTIVE
	return STATUS_UPDATE

/datum/topic_state/air_alarm/href_list(var/mob/user)
	var/list/extra_href = list()
	extra_href["remote_connection"] = TRUE
	extra_href["remote_access"] = has_access(user)

	return extra_href

/datum/topic_state/air_alarm/proc/has_access(var/mob/user)
	return user && (isAI(user) || atmos_control.access.allowed(user) || atmos_control.emagged || air_alarm.rcon_setting == RCON_YES || air_alarm.emagged || (air_alarm.alarm_area.atmosalm && air_alarm.rcon_setting == RCON_AUTO))
