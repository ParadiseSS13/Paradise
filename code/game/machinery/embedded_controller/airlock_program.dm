//Handles the control of airlocks

#define STATE_IDLE			0
#define STATE_PREPARE		1
#define STATE_DEPRESSURIZE	2
#define STATE_PRESSURIZE	3

#define TARGET_NONE			0
#define TARGET_INOPEN		-1
#define TARGET_OUTOPEN		-2


/datum/computer/file/embedded_program/airlock
	var/tag_exterior_door
	var/tag_interior_door
	var/tag_airpump
	var/tag_chamber_sensor
	var/tag_exterior_sensor
	var/tag_interior_sensor
	var/tag_airlock_mech_sensor
	var/tag_shuttle_mech_sensor

	var/state = STATE_IDLE
	var/target_state = TARGET_NONE

/datum/computer/file/embedded_program/airlock/New(var/obj/machinery/embedded_controller/M)
	..(M)

	memory["chamber_sensor_pressure"] = ONE_ATMOSPHERE
	memory["external_sensor_pressure"] = 0					//assume vacuum for simple airlock controller
	memory["internal_sensor_pressure"] = ONE_ATMOSPHERE
	memory["exterior_status"] = list(state = "closed", lock = "locked")		//assume closed and locked in case the doors dont report in
	memory["interior_status"] = list(state = "closed", lock = "locked")
	memory["pump_status"] = "unknown"
	memory["target_pressure"] = ONE_ATMOSPHERE
	memory["purge"] = 0
	memory["secure"] = 0

	if (istype(M, /obj/machinery/embedded_controller/radio/airlock))	//if our controller is an airlock controller than we can auto-init our tags
		var/obj/machinery/embedded_controller/radio/airlock/controller = M
		tag_exterior_door = controller.tag_exterior_door? controller.tag_exterior_door : "[id_tag]_outer"
		tag_interior_door = controller.tag_interior_door? controller.tag_interior_door : "[id_tag]_inner"
		tag_airpump = controller.tag_airpump? controller.tag_airpump : "[id_tag]_pump"
		tag_chamber_sensor = controller.tag_chamber_sensor? controller.tag_chamber_sensor : "[id_tag]_sensor"
		tag_exterior_sensor = controller.tag_exterior_sensor
		tag_interior_sensor = controller.tag_interior_sensor
		tag_airlock_mech_sensor = controller.tag_airlock_mech_sensor? controller.tag_airlock_mech_sensor : "[id_tag]_airlock_mech"
		tag_shuttle_mech_sensor = controller.tag_shuttle_mech_sensor? controller.tag_shuttle_mech_sensor : "[id_tag]_shuttle_mech"
		memory["secure"] = controller.tag_secure

		spawn(10)
			signalDoor(tag_exterior_door, "update")		//signals connected doors to update their status
			signalDoor(tag_interior_door, "update")

/datum/computer/file/embedded_program/airlock/receive_signal(datum/signal/signal, receive_method, receive_param)
	var/receive_tag = signal.data["tag"]
	if(!receive_tag) return

	if(receive_tag==tag_chamber_sensor)
		if(signal.data["pressure"])
			memory["chamber_sensor_pressure"] = text2num(signal.data["pressure"])

	else if(receive_tag==tag_exterior_sensor)
		memory["external_sensor_pressure"] = text2num(signal.data["pressure"])

	else if(receive_tag==tag_interior_sensor)
		memory["internal_sensor_pressure"] = text2num(signal.data["pressure"])

	else if(receive_tag==tag_exterior_door)
		memory["exterior_status"]["state"] = signal.data["door_status"]
		memory["exterior_status"]["lock"] = signal.data["lock_status"]

	else if(receive_tag==tag_interior_door)
		memory["interior_status"]["state"] = signal.data["door_status"]
		memory["interior_status"]["lock"] = signal.data["lock_status"]

	else if(receive_tag==tag_airpump)
		if(signal.data["power"])
			memory["pump_status"] = signal.data["direction"]
		else
			memory["pump_status"] = "off"

	else if(receive_tag==id_tag)
		if(istype(master, /obj/machinery/embedded_controller/radio/airlock/access_controller))
			switch(signal.data["command"])
				if("cycle_exterior")
					receive_user_command("cycle_ext_door")
				if("cycle_interior")
					receive_user_command("cycle_int_door")
				if("cycle")
					if(memory["interior_status"]["state"] == "open")		//handle backwards compatibility
						receive_user_command("cycle_ext")
					else
						receive_user_command("cycle_int")
		else
			switch(signal.data["command"])
				if("cycle_exterior")
					receive_user_command("cycle_ext")
				if("cycle_interior")
					receive_user_command("cycle_int")
				if("cycle")
					if(memory["interior_status"]["state"] == "open")		//handle backwards compatibility
						receive_user_command("cycle_ext")
					else
						receive_user_command("cycle_int")


/datum/computer/file/embedded_program/airlock/receive_user_command(command)
	var/shutdown_pump = 0
	switch(command)
		if("cycle_ext")
			begin_cycle_out()

		if("cycle_int")
			begin_cycle_in()

		if("cycle_ext_door")
			cycleDoors(TARGET_OUTOPEN)

		if("cycle_int_door")
			cycleDoors(TARGET_INOPEN)

		if("abort")
			stop_cycling()
			/*
			//dont do this. If the airlock can't get enough air to pressurize the person inside is stuck
			state = STATE_PRESSURIZE
			target_state = TARGET_NONE
			memory["target_pressure"] = ONE_ATMOSPHERE
			signalPump(tag_airpump, 1, 1, memory["target_pressure"])
			process()
			*/

		if("force_ext")
			toggleDoor(memory["exterior_status"], tag_exterior_door, memory["secure"], "toggle")

		if("force_int")
			toggleDoor(memory["interior_status"], tag_interior_door, memory["secure"], "toggle")

		if("purge")
			memory["purge"] = !memory["purge"]
			if(memory["purge"])
				toggleDoor(memory["exterior_status"], tag_exterior_door, 1, "close")
				toggleDoor(memory["interior_status"], tag_interior_door, 1, "close")
				state = STATE_DEPRESSURIZE
				target_state = TARGET_NONE
				signalPump(tag_airpump, 1, 0, 0)

		if("secure")
			memory["secure"] = !memory["secure"]
			if(memory["secure"])
				signalDoor(tag_interior_door, "lock")
				signalDoor(tag_exterior_door, "lock")
			else
				signalDoor(tag_interior_door, "unlock")
				signalDoor(tag_exterior_door, "unlock")

	if(shutdown_pump)
		signalPump(tag_airpump, 0)		//send a signal to stop pressurizing


/datum/computer/file/embedded_program/airlock/process()
	if(!state) //Idle
		if(target_state)
			switch(target_state)
				if(TARGET_INOPEN)
					memory["target_pressure"] = memory["internal_sensor_pressure"]
				if(TARGET_OUTOPEN)
					memory["target_pressure"] = memory["external_sensor_pressure"]

			//lock down the airlock before activating pumps
			close_doors()

			state = STATE_PREPARE
		else
			//make sure to return to a sane idle state
			if(memory["pump_status"] != "off")	//send a signal to stop pumping
				signalPump(tag_airpump, 0)

	if ((state == STATE_PRESSURIZE || state == STATE_DEPRESSURIZE) && !check_doors_secured())
		//the airlock will not allow itself to continue to cycle when any of the doors are forced open.
		stop_cycling()

	switch(state)
		if(STATE_PREPARE)
			if (check_doors_secured())
				var/chamber_pressure = memory["chamber_sensor_pressure"]
				var/target_pressure = memory["target_pressure"]

				if(memory["purge"])
					target_pressure = 0

				if(memory["purge"])
					target_pressure = 0

				if(chamber_pressure <= target_pressure)
					state = STATE_PRESSURIZE
					signalPump(tag_airpump, 1, 1, target_pressure)	//send a signal to start pressurizing

				else if(chamber_pressure > target_pressure)
					state = STATE_DEPRESSURIZE
					signalPump(tag_airpump, 1, 0, target_pressure)	//send a signal to start depressurizing

				//Check for vacuum - this is set after the pumps so the pumps are aiming for 0
				if(!memory["target_pressure"])
					memory["target_pressure"] = ONE_ATMOSPHERE * 0.05

		if(STATE_PRESSURIZE)
			if(memory["chamber_sensor_pressure"] >= memory["target_pressure"] * 0.95)
				cycleDoors(target_state)

				state = STATE_IDLE
				target_state = TARGET_NONE

				if(memory["pump_status"] != "off")
					signalPump(tag_airpump, 0)		//send a signal to stop pumping


		if(STATE_DEPRESSURIZE)
			if(memory["purge"])
				if(memory["chamber_sensor_pressure"] <= ONE_ATMOSPHERE * 0.05)
					state = STATE_PRESSURIZE
					signalPump(tag_airpump, 1, 1, memory["target_pressure"])


			else if(memory["chamber_sensor_pressure"] <= memory["target_pressure"] * 1.05)
				cycleDoors(target_state)

				state = STATE_IDLE
				target_state = TARGET_NONE

				//send a signal to stop pumping
				if(memory["pump_status"] != "off")
					signalPump(tag_airpump, 0)


	memory["processing"] = state != target_state

	return 1

//these are here so that other types don't have to make so many assuptions about our implementation

/datum/computer/file/embedded_program/airlock/proc/begin_cycle_in()
	state = STATE_IDLE
	target_state = TARGET_INOPEN

/datum/computer/file/embedded_program/airlock/proc/begin_cycle_out()
	state = STATE_IDLE
	target_state = TARGET_OUTOPEN

/datum/computer/file/embedded_program/airlock/proc/close_doors()
	toggleDoor(memory["interior_status"], tag_interior_door, 1, "close")
	toggleDoor(memory["exterior_status"], tag_exterior_door, 1, "close")

/datum/computer/file/embedded_program/airlock/proc/stop_cycling()
	state = STATE_IDLE
	target_state = TARGET_NONE

/datum/computer/file/embedded_program/airlock/proc/done_cycling()
	return (state == STATE_IDLE && target_state == TARGET_NONE)

//are the doors closed and locked?
/datum/computer/file/embedded_program/airlock/proc/check_exterior_door_secured()
	return (memory["exterior_status"]["state"] == "closed" &&  memory["exterior_status"]["lock"] == "locked")

/datum/computer/file/embedded_program/airlock/proc/check_interior_door_secured()
	return (memory["interior_status"]["state"] == "closed" &&  memory["interior_status"]["lock"] == "locked")

/datum/computer/file/embedded_program/airlock/proc/check_doors_secured()
	var/ext_closed = check_exterior_door_secured()
	var/int_closed = check_interior_door_secured()
	return (ext_closed && int_closed)

/datum/computer/file/embedded_program/airlock/proc/signalDoor(var/tag, var/command)
	var/datum/signal/signal = new
	signal.data["tag"] = tag
	signal.data["command"] = command
	post_signal(signal, RADIO_AIRLOCK)

/datum/computer/file/embedded_program/airlock/proc/signalPump(var/tag, var/power, var/direction, var/pressure)
	var/datum/signal/signal = new
	signal.data = list(
		"tag" = tag,
		"sigtype" = "command",
		"power" = power,
		"direction" = direction,
		"set_external_pressure" = pressure
	)
	post_signal(signal)

//this is called to set the appropriate door state at the end of a cycling process, or for the exterior buttons
/datum/computer/file/embedded_program/airlock/proc/cycleDoors(var/target)
	switch(target)
		if(TARGET_OUTOPEN)
			toggleDoor(memory["interior_status"], tag_interior_door, memory["secure"], "close")
			toggleDoor(memory["exterior_status"], tag_exterior_door, memory["secure"], "open")

		if(TARGET_INOPEN)
			toggleDoor(memory["exterior_status"], tag_exterior_door, memory["secure"], "close")
			toggleDoor(memory["interior_status"], tag_interior_door, memory["secure"], "open")
		if(TARGET_NONE)
			var/command = "unlock"
			if(memory["secure"])
				command = "lock"
			signalDoor(tag_exterior_door, command)
			signalDoor(tag_interior_door, command)

datum/computer/file/embedded_program/airlock/proc/signal_mech_sensor(var/command, var/sensor)
	var/datum/signal/signal = new
	signal.data["tag"] = sensor
	signal.data["command"] = command
	post_signal(signal)

/datum/computer/file/embedded_program/airlock/proc/enable_mech_regulation()
	signal_mech_sensor("enable", tag_shuttle_mech_sensor)
	signal_mech_sensor("enable", tag_airlock_mech_sensor)

/datum/computer/file/embedded_program/airlock/proc/disable_mech_regulation()
	signal_mech_sensor("disable", tag_shuttle_mech_sensor)
	signal_mech_sensor("disable", tag_airlock_mech_sensor)

/*----------------------------------------------------------
toggleDoor()

Sends a radio command to a door to either open or close. If
the command is 'toggle' the door will be sent a command that
reverses it's current state.
Can also toggle whether the door bolts are locked or not,
depending on the state of the 'secure' flag.
Only sends a command if it is needed, i.e. if the door is
already open, passing an open command to this proc will not
send an additional command to open the door again.
----------------------------------------------------------*/
/datum/computer/file/embedded_program/airlock/proc/toggleDoor(var/list/doorStatus, var/doorTag, var/secure, var/command)
	var/doorCommand = null

	if(command == "toggle")
		if(doorStatus["state"] == "open")
			command = "close"
		else if(doorStatus["state"] == "closed")
			command = "open"

	switch(command)
		if("close")
			if(secure)
				if(doorStatus["state"] == "open")
					doorCommand = "secure_close"
				else if(doorStatus["lock"] == "unlocked")
					doorCommand = "lock"
			else
				if(doorStatus["state"] == "open")
					if(doorStatus["lock"] == "locked")
						signalDoor(doorTag, "unlock")
					doorCommand = "close"
				else if(doorStatus["lock"] == "locked")
					doorCommand = "unlock"

		if("open")
			if(secure)
				if(doorStatus["state"] == "closed")
					doorCommand = "secure_open"
				else if(doorStatus["lock"] == "unlocked")
					doorCommand = "lock"
			else
				if(doorStatus["state"] == "closed")
					if(doorStatus["lock"] == "locked")
						signalDoor(doorTag,"unlock")
					doorCommand = "open"
				else if(doorStatus["lock"] == "locked")
					doorCommand = "unlock"

	if(doorCommand)
		signalDoor(doorTag, doorCommand)


#undef STATE_IDLE
#undef STATE_DEPRESSURIZE
#undef STATE_PRESSURIZE

#undef TARGET_NONE
#undef TARGET_INOPEN
#undef TARGET_OUTOPEN