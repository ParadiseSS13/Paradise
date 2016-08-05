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

/obj/machinery/embedded_controller/radio/airlock/initialize()
	..()
	program = new/datum/computer/file/embedded_program/airlock(src)

//Advanced airlock controller for when you want a more versatile airlock controller - useful for turning simple access control rooms into airlocks
/obj/machinery/embedded_controller/radio/airlock/advanced_airlock_controller
	name = "Advanced Airlock Controller"

/obj/machinery/embedded_controller/radio/airlock/advanced_airlock_controller/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]

	data = list(
		"chamber_pressure" = round(program.memory["chamber_sensor_pressure"]),
		"external_pressure" = round(program.memory["external_sensor_pressure"]),
		"internal_pressure" = round(program.memory["internal_sensor_pressure"]),
		"processing" = program.memory["processing"],
		"purge" = program.memory["purge"],
		"secure" = program.memory["secure"]
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "advanced_airlock_console.tmpl", name, 470, 290)

		ui.set_initial_data(data)

		ui.open()

		ui.set_auto_update(1)

/obj/machinery/embedded_controller/radio/airlock/advanced_airlock_controller/Topic(href, href_list)
	if(..())
		return 1

	usr.set_machine(src)
	src.add_fingerprint(usr)

	var/clean = 0
	switch(href_list["command"])	//anti-HTML-hacking checks
		if("cycle_ext")
			clean = 1
		if("cycle_int")
			clean = 1
		if("force_ext")
			clean = 1
		if("force_int")
			clean = 1
		if("abort")
			clean = 1
		if("purge")
			clean = 1
		if("secure")
			clean = 1

	if(clean)
		program.receive_user_command(href_list["command"])

	return 1


//Airlock controller for airlock control - most airlocks on the station use this
/obj/machinery/embedded_controller/radio/airlock/airlock_controller
	name = "Airlock Controller"
	tag_secure = 1

/obj/machinery/embedded_controller/radio/airlock/airlock_controller/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]

	data = list(
		"chamber_pressure" = round(program.memory["chamber_sensor_pressure"]),
		"exterior_status" = program.memory["exterior_status"],
		"interior_status" = program.memory["interior_status"],
		"processing" = program.memory["processing"],
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "simple_airlock_console.tmpl", name, 470, 290)

		ui.set_initial_data(data)

		ui.open()

		ui.set_auto_update(1)

/obj/machinery/embedded_controller/radio/airlock/airlock_controller/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	src.add_fingerprint(usr)

	var/clean = 0
	switch(href_list["command"])	//anti-HTML-hacking checks
		if("cycle_ext")
			clean = 1
		if("cycle_int")
			clean = 1
		if("force_ext")
			clean = 1
		if("force_int")
			clean = 1
		if("abort")
			clean = 1

	if(clean)
		program.receive_user_command(href_list["command"])

	return 1


//Access controller for door control - used in virology and the like
/obj/machinery/embedded_controller/radio/airlock/access_controller
	icon = 'icons/obj/airlock_machines.dmi'
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

/obj/machinery/embedded_controller/radio/airlock/access_controller/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]

	data = list(
		"exterior_status" = program.memory["exterior_status"],
		"interior_status" = program.memory["interior_status"],
		"processing" = program.memory["processing"]
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "door_access_console.tmpl", name, 330, 220)

		ui.set_initial_data(data)

		ui.open()

		ui.set_auto_update(1)

/obj/machinery/embedded_controller/radio/airlock/access_controller/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	src.add_fingerprint(usr)

	var/clean = 0
	switch(href_list["command"])	//anti-HTML-hacking checks
		if("cycle_ext_door")
			clean = 1
		if("cycle_int_door")
			clean = 1
		if("force_ext")
			if(program.memory["interior_status"]["state"] == "closed")
				clean = 1
		if("force_int")
			if(program.memory["exterior_status"]["state"] == "closed")
				clean = 1

	if(clean)
		program.receive_user_command(href_list["command"])

	return 1