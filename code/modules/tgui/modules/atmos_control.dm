/datum/ui_module/atmos_control
	name = "Atmospherics Control"

/datum/ui_module/atmos_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("open_alarm")
			var/obj/machinery/alarm/alarm = locate(params["aref"]) in GLOB.air_alarms
			if(alarm)
				alarm.ui_interact(usr, master_ui = ui, state = GLOB.always_state) // ALWAYS is intentional here, as the master_ui pass will prevent fuckery

/datum/ui_module/atmos_control/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "AtmosControl", name, 800, 600, master_ui, state)

		// Send nanomaps
		var/datum/asset/nanomaps = get_asset_datum(/datum/asset/simple/nanomaps)
		nanomaps.send(user)

		ui.open()

/datum/ui_module/atmos_control/ui_data(mob/user)
	var/list/data = list()
	data["alarms"] = GLOB.air_alarm_repository.air_alarm_data(GLOB.air_alarms, target_z=level_name_to_num(MAIN_STATION))

	return data
