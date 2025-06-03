/datum/ui_module/atmos_control
	name = "Atmospherics Control"
	var/parent_area_type
	var/z_level

/datum/ui_module/atmos_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("open_alarm")
			var/obj/machinery/alarm/alarm = locate(params["aref"]) in GLOB.air_alarms
			if(alarm)
				alarm.ui_interact(usr)

/datum/ui_module/atmos_control/ui_state(mob/user)
	if(isliving(usr) && !issilicon(usr))
		return GLOB.human_adjacent_state
	return GLOB.default_state

/datum/ui_module/atmos_control/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosControl", name)
		ui.open()

/datum/ui_module/atmos_control/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/nanomaps)
	)

/datum/ui_module/atmos_control/ui_data(mob/user)
	var/list/alarms_on_net = GLOB.air_alarms
	// default value means main station atmos control
	if(parent_area_type)
		alarms_on_net = list()
		for(var/obj/machinery/alarm/air_alarm in GLOB.air_alarms)
			if(air_alarm.alarm_area.type in typesof(parent_area_type))
				alarms_on_net |= air_alarm

	var/list/data = list()
	data["alarms"] = GLOB.air_alarm_repository.air_alarm_data(alarms_on_net, target_z = z_level)

	return data
