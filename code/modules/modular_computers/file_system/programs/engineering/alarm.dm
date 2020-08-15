/datum/computer_file/program/alarm_monitor
	filename = "alarmmonitor"
	filedesc = "Alarm Monitoring"
	ui_header = "alarm_green.gif"
	program_icon_state = "alert-green"
	extended_desc = "This program provides visual interface for station's alarm system."
	requires_ntnet = 1
	network_destination = "alarm monitoring network"
	size = 5
	var/list/datum/alarm_handler/alarm_handlers

/datum/computer_file/program/alarm_monitor/New()
	..()
	alarm_handlers = list(SSalarms.atmosphere_alarm, SSalarms.fire_alarm, SSalarms.power_alarm)
	for(var/datum/alarm_handler/AH in alarm_handlers)
		AH.register(src, /datum/computer_file/program/alarm_monitor/proc/update_icon)

/datum/computer_file/program/alarm_monitor/Destroy()
	for(var/datum/alarm_handler/AH in alarm_handlers)
		AH.unregister(src)
	QDEL_NULL(alarm_handlers)
	return ..()

/datum/computer_file/program/alarm_monitor/proc/update_icon()
	for(var/datum/alarm_handler/AH in alarm_handlers)
		if(AH.has_major_alarms())
			program_icon_state = "alert-red"
			ui_header = "alarm_red.gif"
			update_computer_icon()
			return 1
	program_icon_state = "alert-green"
	ui_header = "alarm_green.gif"
	update_computer_icon()
	return 0

/datum/computer_file/program/alarm_monitor/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/headers)
		assets.send(user)
		ui = new(user, src, ui_key, "alarm_monitor.tmpl", "Alarm Monitoring", 575, 700)
		ui.set_auto_update(1)
		ui.set_layout_key("program")
		ui.open()

/datum/computer_file/program/alarm_monitor/ui_data(mob/user)
	var/list/data = get_header_data()

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
