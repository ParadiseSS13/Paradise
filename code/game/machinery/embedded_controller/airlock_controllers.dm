//base type for controllers of two-door systems
/obj/machinery/airlock_controller
	layer = ABOVE_WINDOW_LAYER
	// Setup parameters only
	var/tag_exterior_door
	var/tag_interior_door
	var/tag_airpump
	var/tag_chamber_sensor
	var/tag_exterior_sensor
	var/tag_interior_sensor
	var/tag_airlock_mech_sensor
	var/tag_shuttle_mech_sensor

	var/datum/computer/file/embedded_program/program	//the currently executing program

	name = "Embedded Controller"
	anchored = TRUE

	use_power = IDLE_POWER_USE
	idle_power_usage = 10

	var/on = TRUE

/obj/machinery/airlock_controller/Initialize(mapload)
	. = ..()
	program = new/datum/computer/file/embedded_program/airlock(src)

/obj/machinery/airlock_controller/Destroy()
	QDEL_NULL(program)
	return ..()

//Airlock controller for airlock control - most airlocks on the station use this
/obj/machinery/airlock_controller/air_cycler
	name = "Airlock Controller"

/obj/machinery/airlock_controller/air_cycler/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/airlock_controller/air_cycler/LateInitialize()
	// Do setup of stuff here
	return


/obj/machinery/airlock_controller/air_cycler/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ExternalAirlockController", name, 470, 290, master_ui, state)
		ui.open()

/obj/machinery/airlock_controller/air_cycler/ui_data(mob/user)
	var/list/data = list()

	data["chamber_pressure"] = round(program.memory["chamber_sensor_pressure"])
	data["exterior_status"] = program.memory["exterior_status"]
	data["interior_status"] = program.memory["interior_status"]
	data["processing"] = program.memory["processing"]

	return data


/obj/machinery/airlock_controller/air_cycler/ui_act(action, params)
	if(..())
		return

	add_fingerprint(usr)

	var/list/allowed_actions = list("cycle_ext", "cycle_int", "force_ext", "force_int", "abort")
	if(action in allowed_actions)	//anti-HTML-hacking checks
		program.receive_user_command(action)

	return TRUE


//Access controller for door control - used in virology and the like
/obj/machinery/airlock_controller/access_controller
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_control_standby"

	name = "Access Controller"

/obj/machinery/airlock_controller/access_controller/update_icon_state()
	if(on && program)
		if(program.memory["processing"])
			icon_state = "access_control_process"
		else
			icon_state = "access_control_standby"
	else
		icon_state = "access_control_off"

/obj/machinery/airlock_controller/access_controller/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "AirlockAccessController", name, 470, 290, master_ui, state)
		ui.open()

/obj/machinery/airlock_controller/access_controller/ui_data(mob/user)
	var/list/data = list()

	data["exterior_status"] = program.memory["exterior_status"]
	data["interior_status"] = program.memory["interior_status"]
	data["processing"] = program.memory["processing"]

	return data

/obj/machinery/airlock_controller/access_controller/ui_act(action, params)
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

/obj/machinery/airlock_controller/process()
	#warn remove the /datum/computer/file/embedded_program/airlock path and integrate it here. its not used anywhere else
	if(program)
		program.process()

	update_icon(UPDATE_ICON_STATE)
	src.updateDialog()

/obj/machinery/airlock_controller/attack_ghost(mob/user as mob)
	ui_interact(user)

/obj/machinery/airlock_controller/attack_ai(mob/user as mob)
	ui_interact(user)

/obj/machinery/airlock_controller/attack_hand(mob/user as mob)
	if(!user.IsAdvancedToolUser())
		return FALSE
	ui_interact(user)


/obj/machinery/airlock_controller/update_icon_state()
	if(on && program)
		if(program.memory["processing"])
			icon_state = "airlock_control_process"
		else
			icon_state = "airlock_control_standby"
	else
		icon_state = "airlock_control_off"
