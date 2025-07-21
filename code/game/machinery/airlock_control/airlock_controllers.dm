//base type for controllers of two-door systems
/obj/machinery/airlock_controller
	layer = ON_EDGED_TURF_LAYER
	name = "airlock controller"
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"
	anchored = TRUE
	idle_power_consumption = 10

	// Setup vars

	/// Airlock ID for all exterior doors to link to.
	var/ext_door_link_id
	/// Airlock ID for all interior doors to link to.
	var/int_door_link_id
	/// Button ID for all exterior buttons to link to.
	var/ext_button_link_id
	/// Vutton ID for all exterior buttons to link to.
	var/int_button_link_id

	// Actual holding vars
	/// All exterior doors to control. Soft-refs only.
	var/list/exterior_doors = list()
	/// All interior doors to control. Soft-refs only.
	var/list/interior_doors = list()

	/// Current state (IDLE, PREPARE, DEPRESSURIZE, PRESSURIZE)
	var/state = CONTROL_STATE_IDLE
	/// Target state (MONE, INOPEN, OUTOPEN)
	var/target_state = TARGET_NONE

	/// Vent ID for all vents to link to.
	var/vent_link_id
	/// All vents to control. Soft-refs only.
	var/list/vents = list()

	// Program vars
	var/target_pressure

/obj/machinery/airlock_controller/proc/link_all_items()
	for(var/obj/machinery/door/airlock/A in GLOB.airlocks)
		if(A.id_tag == int_door_link_id)
			interior_doors |= A.UID()
		if(A.id_tag == ext_door_link_id)
			exterior_doors |= A.UID()

	if(!length(interior_doors))
		stack_trace("[src] at [x],[y],[z] didnt setup any interior airlocks! Please double check the IDs!")
	if(!length(exterior_doors))
		stack_trace("[src] at [x],[y],[z] didnt setup any exterior airlocks! Please double check the IDs!")

	// Track amount
	var/ib_setup = 0
	var/eb_setup = 0
	for(var/obj/machinery/access_button/B as anything in GLOB.all_airlock_access_buttons)
		if(B.autolink_id == int_button_link_id)
			B.setup(src, MODE_INTERIOR)
			ib_setup++
		if(B.autolink_id == ext_button_link_id)
			B.setup(src, MODE_EXTERIOR)
			eb_setup++

	if(!ib_setup)
		stack_trace("[src] at [x],[y],[z] didnt setup any interior buttons! Please double check the IDs!")
	if(!eb_setup)
		stack_trace("[src] at [x],[y],[z] didnt setup any exterior buttons! Please double check the IDs!")

/obj/machinery/airlock_controller/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/airlock_controller/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/airlock_controller/attack_hand(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	ui_interact(user)

/obj/machinery/airlock_controller/update_icon_state()
	if(has_power(power_channel))
		if(state != target_state)
			icon_state = "airlock_control_process"
		else
			icon_state = "airlock_control_standby"
	else
		icon_state = "airlock_control_off"

/obj/machinery/airlock_controller/proc/handle_button(button_mode)
	// dm please give me abstracts I beg
	CRASH("handle_button() not overridden for [type]")

/obj/machinery/airlock_controller/ui_act(action, params)
	if(..())
		return

	add_fingerprint(usr)

	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return TRUE

	switch(action)
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

		if("force_ext")
			toggleDoors(exterior_doors, "toggle")

		if("force_int")
			toggleDoors(interior_doors, "toggle")

	return TRUE

/obj/machinery/airlock_controller/process()
	if(!state) //Idle
		if(target_state)
			switch(target_state)
				if(TARGET_INOPEN)
					target_pressure = ONE_ATMOSPHERE
				if(TARGET_OUTOPEN)
					target_pressure = 0

			//lock down the airlock before activating pumps
			close_doors()

			state = CONTROL_STATE_PREPARE
		else
			//make sure to return to a sane idle state
			signalPumps(FALSE)

	if((state == CONTROL_STATE_PRESSURIZE || state == CONTROL_STATE_DEPRESSURIZE) && !check_doors_secured())
		//the airlock will not allow itself to continue to cycle when any of the doors are forced open.
		stop_cycling()

	var/turf/T = get_turf(src)
	var/chamber_pressure = T.get_readonly_air().return_pressure()
	switch(state)
		if(CONTROL_STATE_PREPARE)
			if(check_doors_secured())
				if(chamber_pressure < target_pressure)
					state = CONTROL_STATE_PRESSURIZE
					signalPumps(TRUE, TRUE, target_pressure)	//send a signal to start pressurizing

				else if(chamber_pressure > target_pressure)
					state = CONTROL_STATE_DEPRESSURIZE
					signalPumps(TRUE, FALSE, target_pressure)	//send a signal to start depressurizing

				else // Prevent airlock from deadlocking
					cycleDoors(target_state)

					state = CONTROL_STATE_IDLE
					target_state = TARGET_NONE

				//Check for vacuum - this is set after the pumps so the pumps are aiming for 0
				if(!target_pressure)
					target_pressure = ONE_ATMOSPHERE * 0.05

		if(CONTROL_STATE_PRESSURIZE)
			if(chamber_pressure >= (target_pressure * 0.95))
				cycleDoors(target_state)

				state = CONTROL_STATE_IDLE
				target_state = TARGET_NONE

				signalPumps(FALSE) //send a signal to stop pumping


		if(CONTROL_STATE_DEPRESSURIZE)
			if(chamber_pressure <= (target_pressure * 1.05))
				cycleDoors(target_state)

				state = CONTROL_STATE_IDLE
				target_state = TARGET_NONE

				//send a signal to stop pumping
				signalPumps(FALSE)

	return TRUE

/obj/machinery/airlock_controller/proc/begin_cycle_in()
	state = CONTROL_STATE_IDLE
	target_state = TARGET_INOPEN

/obj/machinery/airlock_controller/proc/begin_cycle_out()
	state = CONTROL_STATE_IDLE
	target_state = TARGET_OUTOPEN

/obj/machinery/airlock_controller/proc/close_doors()
	toggleDoors(interior_doors, "close")
	toggleDoors(exterior_doors, "close")

/obj/machinery/airlock_controller/proc/stop_cycling()
	state = CONTROL_STATE_IDLE
	target_state = TARGET_NONE

/obj/machinery/airlock_controller/proc/done_cycling()
	return (state == CONTROL_STATE_IDLE && target_state == TARGET_NONE)

//are the doors closed and locked?
/obj/machinery/airlock_controller/proc/check_doors_match_state_uid(list/door_uids, door_state)
	var/list/obj/machinery/door/airlock/temp_airlocks = list()
	for(var/airlock_uid in door_uids)
		var/obj/machinery/door/airlock/A = locateUID(airlock_uid)
		if(QDELETED(A))
			door_uids -= airlock_uid
			continue

		temp_airlocks += A

	return check_doors_match_state(temp_airlocks, door_state)

/obj/machinery/airlock_controller/proc/check_doors_match_state(list/doors, door_state)
	for(var/obj/machinery/door/airlock/A as anything in doors)
		switch(door_state)
			if("open")
				if(A.density)
					return FALSE // Fail if door is dense (closed) on open check
			if("closed")
				if(!A.density)
					return FALSE // Fail if door is not dense (open) on closed check
			if("locked")
				if(!A.locked)
					return FALSE // Fail if door is not locked on locked check
			if("unlocked")
				if(A.locked)
					return FALSE // Fail if door is locked on unlock check

	// We passed!
	return TRUE

/obj/machinery/airlock_controller/proc/check_doors_secured()
	var/ext_closed = (check_doors_match_state_uid(exterior_doors, "closed") && check_doors_match_state_uid(exterior_doors, "locked"))
	var/int_closed = (check_doors_match_state_uid(interior_doors, "closed") && check_doors_match_state_uid(interior_doors, "locked"))
	return (ext_closed && int_closed)

/obj/machinery/airlock_controller/proc/signalDoors(list/uids, command)
	for(var/airlock_uid in uids)
		var/obj/machinery/door/airlock/A = locateUID(airlock_uid)
		if(QDELETED(A))
			uids -= airlock_uid
			continue

		A.airlock_cycle_callback(command)

/obj/machinery/airlock_controller/proc/signalPumps(power, direction, pressure)
	for(var/vent_uid in vents)
		var/obj/machinery/atmospherics/unary/vent_pump/V = locateUID(vent_uid)
		if(QDELETED(V))
			vents -= vent_uid
			continue
		if(V.on == FALSE && power == FALSE) // Don't bother if it's already off
			continue
		V.on = power
		V.releasing = direction
		V.external_pressure_bound = pressure
		V.update_icon(UPDATE_ICON_STATE)


//this is called to set the appropriate door state at the end of a cycling process, or for the exterior buttons
/obj/machinery/airlock_controller/proc/cycleDoors(target)
	switch(target)
		if(TARGET_OUTOPEN)
			toggleDoors(interior_doors, "close")
			toggleDoors(exterior_doors, "open")
		if(TARGET_INOPEN)
			toggleDoors(interior_doors, "open")
			toggleDoors(exterior_doors, "close")
		if(TARGET_NONE)
			signalDoors(interior_doors, "unlock")
			signalDoors(exterior_doors, "unlock")

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
/obj/machinery/airlock_controller/proc/toggleDoors(list/doors, command)
	var/doorCommand = null

	// Cache this. it will be expensive otherwise.
	var/list/obj/machinery/door/airlock/airlocks = list()
	for(var/airlock_uid in doors)
		var/obj/machinery/door/airlock/A = locateUID(airlock_uid)
		if(QDELETED(A))
			doors -= airlock_uid
			continue

		airlocks += A


	if(command == "toggle")
		if(check_doors_match_state(airlocks, "open"))
			command = "close"
		else if(check_doors_match_state(airlocks, "closed"))
			command = "open"

	switch(command)
		if("close")
			if(check_doors_match_state(airlocks, "open"))
				doorCommand = "secure_close"
			else if(check_doors_match_state(airlocks, "unlocked"))
				doorCommand = "lock"

		if("open")
			if(check_doors_match_state(airlocks, "closed"))
				doorCommand = "secure_open"
			else if(check_doors_match_state(airlocks, "unlocked"))
				doorCommand = "lock"

	if(doorCommand)
		signalDoors(doors, doorCommand)


/* =============================== ACCESS CONTROLLER - No cycling required */
/obj/machinery/airlock_controller/access_controller
	name = "airlock access controller"
	icon_state = "access_control_standby"

/obj/machinery/airlock_controller/access_controller/update_icon_state()
	if(has_power(power_channel))
		if(state != target_state)
			icon_state = "access_control_process"
		else
			icon_state = "access_control_standby"
	else
		icon_state = "access_control_off"

/obj/machinery/airlock_controller/access_controller/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/airlock_controller/access_controller/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirlockAccessController", name)
		ui.open()

/obj/machinery/airlock_controller/access_controller/ui_data(mob/user)
	var/list/data = list()

	data["exterior_status"] = (check_doors_match_state_uid(exterior_doors, "closed") ? "closed" : "open")
	data["interior_status"] = (check_doors_match_state_uid(interior_doors, "closed") ? "closed" : "open")
	data["processing"] = (state != target_state)

	return data

/obj/machinery/airlock_controller/access_controller/handle_button(button_mode)
	switch(button_mode)
		if(MODE_INTERIOR)
			cycleDoors(TARGET_INOPEN)
		if(MODE_EXTERIOR)
			cycleDoors(TARGET_OUTOPEN)

/* =============================== AIR CYCLER - Ensures internal pressure matches (just about) the void or the normal atmosphere */
/obj/machinery/airlock_controller/air_cycler/link_all_items()
	. = ..()

	for(var/obj/machinery/atmospherics/unary/vent_pump/V as anything in GLOB.all_vent_pumps)
		if(V.autolink_id == vent_link_id)
			vents += V.UID()

	if(!length(vents))
		stack_trace("[src] at [x],[y],[z] didnt setup any vents! Please double check the IDs!")


/obj/machinery/airlock_controller/air_cycler/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/airlock_controller/air_cycler/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ExternalAirlockController", name)
		ui.open()

/obj/machinery/airlock_controller/air_cycler/ui_data(mob/user)
	var/list/data = list()

	var/turf/T = get_turf(src)
	var/chamber_pressure = T.get_readonly_air().return_pressure()
	data["chamber_pressure"] = round(chamber_pressure, 1)
	data["exterior_status"] = (check_doors_match_state_uid(exterior_doors, "closed") ? "closed" : "open")
	data["interior_status"] = (check_doors_match_state_uid(interior_doors, "closed") ? "closed" : "open")
	data["processing"] = (state != target_state)

	return data

/obj/machinery/airlock_controller/air_cycler/handle_button(button_mode)
	switch(button_mode)
		if(MODE_INTERIOR)
			begin_cycle_in()
		if(MODE_EXTERIOR)
			begin_cycle_out()

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/airlock_controller/air_cycler, 25, 25)
