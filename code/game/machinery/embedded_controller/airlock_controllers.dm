//base type for controllers of two-door systems
/obj/machinery/embedded_controller/radio/airlock
	// Setup parameters only
	radio_filter = RADIO_AIRLOCK
	var/tag_exterior_door
	var/tag_interior_door
	var/tag_airpump
	var/tag_chamber_sensor
	var/tag_exterior_sensor
	var/tag_interior_sensor
	var/tag_airlock_mech_sensor
	var/tag_shuttle_mech_sensor
	var/tag_secure = 0

/obj/machinery/embedded_controller/radio/airlock/Initialize()
	..()
	program = new/datum/computer/file/embedded_program/airlock(src)

//Airlock controller for airlock control - most airlocks on the station use this
/obj/machinery/embedded_controller/radio/airlock/airlock_controller
	name = "Airlock Controller"
	tag_secure = 1

/obj/machinery/embedded_controller/radio/airlock/airlock_controller/Initialize(mapload, given_id_tag, given_frequency, given_tag_exterior_door, given_tag_interior_door, given_tag_airpump, given_tag_chamber_sensor)
	if(given_id_tag)
		id_tag = given_id_tag
	if(given_frequency)
		set_frequency(given_frequency)
	if(given_tag_exterior_door)
		tag_exterior_door = given_tag_exterior_door
	if(given_tag_interior_door)
		tag_interior_door = given_tag_interior_door
	if(given_tag_airpump)
		tag_airpump = given_tag_airpump
	if(given_tag_chamber_sensor)
		tag_chamber_sensor = given_tag_chamber_sensor
	..()

/obj/machinery/embedded_controller/radio/airlock/airlock_controller/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ExternalAirlockController", name, 470, 290, master_ui, state)
		ui.open()

/obj/machinery/embedded_controller/radio/airlock/airlock_controller/ui_data(mob/user)
	var/list/data = list()

	data["chamber_pressure"] = round(program.memory["chamber_sensor_pressure"])
	data["exterior_status"] = program.memory["exterior_status"]
	data["interior_status"] = program.memory["interior_status"]
	data["processing"] = program.memory["processing"]

	return data


/obj/machinery/embedded_controller/radio/airlock/airlock_controller/ui_act(action, params)
	if(..())
		return

	add_fingerprint(usr)

	var/list/allowed_actions = list("cycle_ext", "cycle_int", "force_ext", "force_int", "abort")
	if(action in allowed_actions)	//anti-HTML-hacking checks
		program.receive_user_command(action)

	return TRUE


//Access controller for door control - used in virology and the like
/obj/machinery/embedded_controller/radio/airlock/access_controller
	icon = 'icons/obj/machines/airlock_machines.dmi'
	icon_state = "access_control_standby"

	name = "Access Controller"
	tag_secure = 1

/obj/machinery/embedded_controller/radio/airlock/access_controller/update_icon()
	if(on && program)
		if(program.memory["processing"])
			icon_state = "access_control_process"
		else
			icon_state = "access_control_standby"
	else
		icon_state = "access_control_off"

/obj/machinery/embedded_controller/radio/airlock/access_controller/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "AirlockAccessController", name, 470, 290, master_ui, state)
		ui.open()

/obj/machinery/embedded_controller/radio/airlock/access_controller/ui_data(mob/user)
	var/list/data = list()

	data["exterior_status"] = program.memory["exterior_status"]
	data["interior_status"] = program.memory["interior_status"]
	data["processing"] = program.memory["processing"]

	return data

/obj/machinery/embedded_controller/radio/airlock/access_controller/ui_act(action, params)
	if(..())
		return

	add_fingerprint(usr)

	var/clean = FALSE

	// Repeat the frontend check to make sure only allowed command are sent. You are only allowed to lock or cycle exterior if exterior is open
	// Vice versa for internal

	switch(action)
		if("cycle_ext_door")
			clean = TRUE
		if("cycle_int_door")
			clean = TRUE
		if("force_ext") // Cannot force exterior if interior open
			if(program.memory["interior_status"]["state"] == "closed" && program.memory["exterior_status"]["state"] == "open")
				clean = TRUE
		if("force_int") // Cannot force interior if exterior open
			if(program.memory["exterior_status"]["state"] == "closed" && program.memory["interior_status"]["state"] == "open")
				clean = TRUE

	if(clean)
		program.receive_user_command(action)

	return TRUE

