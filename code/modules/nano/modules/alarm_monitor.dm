/datum/nano_module/alarm_monitor
	name = "Alarm monitor"
	var/list_cameras = 0						// Whether or not to list camera references. A future goal would be to merge this with the enginering/security camera console. Currently really only for AI-use.
	var/list/datum/alarm_handler/alarm_handlers // The particular list of alarm handlers this alarm monitor should present to the user.

/datum/nano_module/alarm_monitor/all/New()
	..()
	alarm_handlers = list(atmosphere_alarm, burglar_alarm, camera_alarm, fire_alarm, motion_alarm, power_alarm)

/datum/nano_module/alarm_monitor/engineering/New()
	..()
	alarm_handlers = list(atmosphere_alarm, fire_alarm, power_alarm)

/datum/nano_module/alarm_monitor/security/New()
	..()
	alarm_handlers = list(burglar_alarm, camera_alarm, motion_alarm)

/datum/nano_module/alarm_monitor/proc/register(var/object, var/procName)
	for(var/datum/alarm_handler/AH in alarm_handlers)
		AH.register(object, procName)

/datum/nano_module/alarm_monitor/proc/unregister(var/object)
	for(var/datum/alarm_handler/AH in alarm_handlers)
		AH.unregister(object)

/datum/nano_module/alarm_monitor/proc/all_alarms()
	var/list/all_alarms = new()
	for(var/datum/alarm_handler/AH in alarm_handlers)
		all_alarms += AH.alarms

	return all_alarms

/datum/nano_module/alarm_monitor/proc/major_alarms()
	var/list/all_alarms = new()
	for(var/datum/alarm_handler/AH in alarm_handlers)
		all_alarms += AH.major_alarms()

	return all_alarms

/datum/nano_module/alarm_monitor/proc/minor_alarms()
	var/list/all_alarms = new()
	for(var/datum/alarm_handler/AH in alarm_handlers)
		all_alarms += AH.minor_alarms()

	return all_alarms

/datum/nano_module/alarm_monitor/Topic(ref, href_list)
	if(..())
		return 1
	if(href_list["switchTo"])
		var/obj/machinery/camera/C = locate(href_list["switchTo"]) in cameranet.cameras
		if(!C || !isAI(usr))
			return

		usr.switch_to_camera(C)
		return 1

/datum/nano_module/alarm_monitor/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = default_state)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "alarm_monitor.tmpl", "Alarm Monitoring Console", 800, 800, state = state)
		ui.open()
		ui.set_auto_update(1)

/datum/nano_module/alarm_monitor/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]

	var/categories[0]
	for(var/datum/alarm_handler/AH in alarm_handlers)
		categories[++categories.len] = list("category" = AH.category, "alarms" = list())
		for(var/datum/alarm/A in AH.major_alarms())
			var/cameras[0]
			var/lost_sources[0]

			if(isAI(user))
				for(var/obj/machinery/camera/C in A.cameras())
					cameras[++cameras.len] = C.nano_structure()
			for(var/datum/alarm_source/AS in A.sources)
				if(!AS.source)
					lost_sources[++lost_sources.len] = AS.source_name

			categories[categories.len]["alarms"] += list(list(
					"name" = sanitize(A.alarm_name()),
					"origin_lost" = A.origin == null,
					"has_cameras" = cameras.len,
					"cameras" = cameras,
					"lost_sources" = lost_sources.len ? sanitize(english_list(lost_sources, nothing_text = "", and_text = ", ")) : ""))
	data["categories"] = categories

	return data
