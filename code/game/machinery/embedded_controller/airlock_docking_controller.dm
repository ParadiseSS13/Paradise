//a docking port based on an airlock
/obj/machinery/embedded_controller/radio/airlock/docking_port
	name = "docking port controller"
	var/datum/computer/file/embedded_program/airlock/docking/airlock_program
	var/datum/computer/file/embedded_program/docking/airlock/docking_program
	tag_secure = 1

/obj/machinery/embedded_controller/radio/airlock/docking_port/initialize()
	..()
	airlock_program = new/datum/computer/file/embedded_program/airlock/docking(src)
	docking_program = new/datum/computer/file/embedded_program/docking/airlock(src, airlock_program)
	program = docking_program

/obj/machinery/embedded_controller/radio/airlock/docking_port/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]

	data = list(
		"chamber_pressure" = round(airlock_program.memory["chamber_sensor_pressure"]),
		"exterior_status" = airlock_program.memory["exterior_status"],
		"interior_status" = airlock_program.memory["interior_status"],
		"processing" = airlock_program.memory["processing"],
		"docking_status" = docking_program.get_docking_status(),
		"airlock_disabled" = !(docking_program.undocked() || docking_program.override_enabled),
		"override_enabled" = docking_program.override_enabled,
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "docking_airlock_console.tmpl", name, 470, 290)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/embedded_controller/radio/airlock/docking_port/Topic(href, href_list)
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
		if("toggle_override")
			clean = 1

	if(clean)
		program.receive_user_command(href_list["command"])

	return 1



//A docking controller for an airlock based docking port
/datum/computer/file/embedded_program/docking/airlock
	var/datum/computer/file/embedded_program/airlock/docking/airlock_program

/datum/computer/file/embedded_program/docking/airlock/New(var/obj/machinery/embedded_controller/M, var/datum/computer/file/embedded_program/airlock/docking/A)
	..(M)
	airlock_program = A
	airlock_program.master_prog = src

/datum/computer/file/embedded_program/docking/airlock/receive_user_command(command)
	if (command == "toggle_override")
		if (override_enabled)
			disable_override()
		else
			enable_override()
		return

	..(command)
	airlock_program.receive_user_command(command)	//pass along to subprograms

/datum/computer/file/embedded_program/docking/airlock/process()
	airlock_program.process()
	..()

/datum/computer/file/embedded_program/docking/airlock/receive_signal(datum/signal/signal, receive_method, receive_param)
	airlock_program.receive_signal(signal, receive_method, receive_param)	//pass along to subprograms
	..(signal, receive_method, receive_param)

//tell the docking port to start getting ready for docking - e.g. pressurize
/datum/computer/file/embedded_program/docking/airlock/prepare_for_docking()
	airlock_program.begin_cycle_in()

//are we ready for docking?
/datum/computer/file/embedded_program/docking/airlock/ready_for_docking()
	return airlock_program.done_cycling()

//we are docked, open the doors or whatever.
/datum/computer/file/embedded_program/docking/airlock/finish_docking()
	airlock_program.enable_mech_regulators()
	airlock_program.open_doors()

//tell the docking port to start getting ready for undocking - e.g. close those doors.
/datum/computer/file/embedded_program/docking/airlock/prepare_for_undocking()
	airlock_program.stop_cycling()
	airlock_program.close_doors()
	airlock_program.disable_mech_regulators()

//are we ready for undocking?
/datum/computer/file/embedded_program/docking/airlock/ready_for_undocking()
	var/ext_closed = airlock_program.check_exterior_door_secured()
	var/int_closed = airlock_program.check_interior_door_secured()
	return (ext_closed || int_closed)

//An airlock controller to be used by the airlock-based docking port controller.
//Same as a regular airlock controller but allows disabling of the regular airlock functions when docking
/datum/computer/file/embedded_program/airlock/docking
	var/datum/computer/file/embedded_program/docking/airlock/master_prog

/datum/computer/file/embedded_program/airlock/docking/receive_user_command(command)
	if (master_prog.undocked() || master_prog.override_enabled)	//only allow the port to be used as an airlock if nothing is docked here or the override is enabled
		..(command)

/datum/computer/file/embedded_program/airlock/docking/proc/enable_mech_regulators()
	enable_mech_regulation()

/datum/computer/file/embedded_program/airlock/docking/proc/disable_mech_regulators()
	disable_mech_regulation()

/datum/computer/file/embedded_program/airlock/docking/proc/open_doors()
	toggleDoor(memory["interior_status"], tag_interior_door, memory["secure"], "open")
	toggleDoor(memory["exterior_status"], tag_exterior_door, memory["secure"], "open")

/datum/computer/file/embedded_program/airlock/docking/cycleDoors(var/target)
	if (master_prog.undocked() || master_prog.override_enabled)	//only allow the port to be used as an airlock if nothing is docked here or the override is enabled
		..(target)

/*** DEBUG VERBS ***

/datum/computer/file/embedded_program/docking/proc/print_state()
	world << "id_tag: [id_tag]"
	world << "dock_state: [dock_state]"
	world << "control_mode: [control_mode]"
	world << "tag_target: [tag_target]"
	world << "response_sent: [response_sent]"

/datum/computer/file/embedded_program/docking/post_signal(datum/signal/signal, comm_line)
	world << "Program [id_tag] sent a message!"
	print_state()
	world << "[id_tag] sent command \"[signal.data["command"]]\" to \"[signal.data["recipient"]]\""
	..(signal)

/obj/machinery/embedded_controller/radio/airlock/docking_port/verb/view_state()
	set category = "Debug"
	set src in view(1)
	src.program:print_state()

/obj/machinery/embedded_controller/radio/airlock/docking_port/verb/spoof_signal(var/command as text, var/sender as text)
	set category = "Debug"
	set src in view(1)
	var/datum/signal/signal = new
	signal.data["tag"] = sender
	signal.data["command"] = command
	signal.data["recipient"] = id_tag

	src.program:receive_signal(signal)

/obj/machinery/embedded_controller/radio/airlock/docking_port/verb/debug_init_dock(var/target as text)
	set category = "Debug"
	set src in view(1)
	src.program:initiate_docking(target)

/obj/machinery/embedded_controller/radio/airlock/docking_port/verb/debug_init_undock()
	set category = "Debug"
	set src in view(1)
	src.program:initiate_undocking()

*/