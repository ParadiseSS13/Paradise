/*
	These programs are for docking controllers that consist of multiple independent airlocks
	Each airlock has an airlock controller running the child program, and there is one docking controller running the master program
*/

/*
	the master program
*/
/datum/computer/file/embedded_program/docking/multi
	var/list/children_tags
	var/list/children_ready
	var/list/children_override

/datum/computer/file/embedded_program/docking/multi/New(var/obj/machinery/embedded_controller/M)
	..(M)

	if (istype(M,/obj/machinery/embedded_controller/radio/docking_port_multi))	//if our parent controller is the right type, then we can auto-init stuff at construction
		var/obj/machinery/embedded_controller/radio/docking_port_multi/controller = M
		//parse child_tags_txt and create child tags
		children_tags = text2list(controller.child_tags_txt, ";")

	children_ready = list()
	children_override = list()
	for (var/child_tag in children_tags)
		children_ready[child_tag] = 0
		children_override[child_tag] = "disabled"

/datum/computer/file/embedded_program/docking/multi/proc/clear_children_ready_status()
	for (var/child_tag in children_tags)
		children_ready[child_tag] = 0

/datum/computer/file/embedded_program/docking/multi/receive_signal(datum/signal/signal, receive_method, receive_param)
	var/receive_tag = signal.data["tag"]		//for docking signals, this is the sender id
	var/command = signal.data["command"]
	var/recipient = signal.data["recipient"]	//the intended recipient of the docking signal

	if (receive_tag in children_tags)

		//track children status
		if (signal.data["override_status"])
			children_override[receive_tag] = signal.data["override_status"]

		if (recipient == id_tag)
			switch (command)
				if ("ready_for_docking")
					children_ready[receive_tag] = 1
				if ("ready_for_undocking")
					children_ready[receive_tag] = 1
				if ("status_override_enabled")
					children_override[receive_tag] = 1
				if ("status_override_disabled")
					children_override[receive_tag] = 0

	..(signal, receive_method, receive_param)

/datum/computer/file/embedded_program/docking/multi/prepare_for_docking()
	//clear children ready status
	clear_children_ready_status()

	//tell children to prepare for docking
	for (var/child_tag in children_tags)
		send_docking_command(child_tag, "prepare_for_docking")

/datum/computer/file/embedded_program/docking/multi/ready_for_docking()
	//check children ready status
	for (var/child_tag in children_tags)
		if (!children_ready[child_tag])
			return 0
	return 1

/datum/computer/file/embedded_program/docking/multi/finish_docking()
	//tell children to finish docking
	for (var/child_tag in children_tags)
		send_docking_command(child_tag, "finish_docking")

	//clear ready flags
	clear_children_ready_status()

/datum/computer/file/embedded_program/docking/multi/prepare_for_undocking()
	//clear children ready status
	clear_children_ready_status()

	//tell children to prepare for undocking
	for (var/child_tag in children_tags)
		send_docking_command(child_tag, "prepare_for_undocking")

/datum/computer/file/embedded_program/docking/multi/ready_for_undocking()
	//check children ready status
	for (var/child_tag in children_tags)
		if (!children_ready[child_tag])
			return 0
	return 1

/datum/computer/file/embedded_program/docking/multi/finish_undocking()
	//tell children to finish undocking
	for (var/child_tag in children_tags)
		send_docking_command(child_tag, "finish_undocking")

	//clear ready flags
	clear_children_ready_status()




/*
	the child program
	technically should be "slave" but eh... I'm too politically correct.
*/
/datum/computer/file/embedded_program/airlock/multi_docking
	var/master_tag

	var/master_status = "undocked"
	var/override_enabled = 0
	var/docking_enabled = 0
	var/docking_mode = 0	//0 = docking, 1 = undocking
	var/response_sent = 0

/datum/computer/file/embedded_program/airlock/multi_docking/New(var/obj/machinery/embedded_controller/M)
	..(M)

	if (istype(M, /obj/machinery/embedded_controller/radio/airlock/docking_port_multi))	//if our parent controller is the right type, then we can auto-init stuff at construction
		var/obj/machinery/embedded_controller/radio/airlock/docking_port_multi/controller = M
		src.master_tag = controller.master_tag

/datum/computer/file/embedded_program/airlock/multi_docking/receive_user_command(command)
	if (command == "toggle_override")
		if (override_enabled)
			override_enabled = 0
			broadcast_override_status()
		else
			override_enabled = 1
			broadcast_override_status()
		return

	if (!docking_enabled|| override_enabled)	//only allow the port to be used as an airlock if nothing is docked here or the override is enabled
		..(command)

/datum/computer/file/embedded_program/airlock/multi_docking/receive_signal(datum/signal/signal, receive_method, receive_param)
	..()

	var/receive_tag = signal.data["tag"]		//for docking signals, this is the sender id
	var/command = signal.data["command"]
	var/recipient = signal.data["recipient"]	//the intended recipient of the docking signal

	if (receive_tag != master_tag)
		return	//only respond to master

	//track master's status
	if (signal.data["dock_status"])
		master_status = signal.data["dock_status"]

	if (recipient != id_tag)
		return	//this signal is not for us

	switch (command)
		if ("prepare_for_docking")
			docking_enabled = 1
			docking_mode = 0
			response_sent = 0

			if (!override_enabled)
				begin_cycle_in()

		if ("prepare_for_undocking")
			docking_mode = 1
			response_sent = 0

			if (!override_enabled)
				stop_cycling()
				close_doors()
				disable_mech_regulation()

		if ("finish_docking")
			if (!override_enabled)
				enable_mech_regulation()
				open_doors()

		if ("finish_undocking")
			docking_enabled = 0

/datum/computer/file/embedded_program/airlock/multi_docking/process()
	..()

	if (docking_enabled && !response_sent)

		switch (docking_mode)
			if (0)	//docking
				if (ready_for_docking())
					send_signal_to_master("ready_for_docking")
					response_sent = 1
			if (1)	//undocking
				if (ready_for_undocking())
					send_signal_to_master("ready_for_undocking")
					response_sent = 1

//checks if we are ready for docking
/datum/computer/file/embedded_program/airlock/multi_docking/proc/ready_for_docking()
	return done_cycling()

//checks if we are ready for undocking
/datum/computer/file/embedded_program/airlock/multi_docking/proc/ready_for_undocking()
	return check_doors_secured()

/datum/computer/file/embedded_program/airlock/multi_docking/proc/open_doors()
	toggleDoor(memory["interior_status"], tag_interior_door, memory["secure"], "open")
	toggleDoor(memory["exterior_status"], tag_exterior_door, memory["secure"], "open")

/datum/computer/file/embedded_program/airlock/multi_docking/cycleDoors(var/target)
	if (!docking_enabled|| override_enabled)	//only allow the port to be used as an airlock if nothing is docked here or the override is enabled
		..(target)

/datum/computer/file/embedded_program/airlock/multi_docking/proc/send_signal_to_master(var/command)
	var/datum/signal/signal = new
	signal.data["tag"] = id_tag
	signal.data["command"] = command
	signal.data["recipient"] = master_tag
	post_signal(signal)

/datum/computer/file/embedded_program/airlock/multi_docking/proc/broadcast_override_status()
	var/datum/signal/signal = new
	signal.data["tag"] = id_tag
	signal.data["override_status"] = override_enabled? "enabled" : "disabled"
	post_signal(signal)
