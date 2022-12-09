//base type for controllers of two-door systems
/obj/machinery/airlock_controller
	layer = ABOVE_WINDOW_LAYER
	name = "airlock controller"
	icon = 'icons/obj/airlock_machines.dmi'
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10

	// Setup vars

	/// Airlock ID for all exterior doors to link to on LateInitialize()
	var/ext_door_link_id
	/// Airlock ID for all interior doors to link to on LateInitialize()
	var/int_door_link_id
	/// Button ID for all exterior buttons to link to on LateInitialize()
	var/ext_button_link_id
	/// Vutton ID for all exterior buttons to link to on LateInitialize()
	var/int_button_link_id

	// Actual holding vars
	/// All exterior doors to control. Soft-refs only.
	var/list/exterior_doors = list()
	/// All interior doors to control. Soft-refs only.
	var/list/interior_doors = list()

	/// Is external meant to be open?
	var/external_open = FALSE
	/// Is internal meant to be open?
	var/internal_open = FALSE

	/// Current state (IDLE, PREPARE, DEPRESSURIZE, PRESSURIZE)
	var/state = CONTROL_STATE_IDLE
	/// Target state (MONE, INOPEN, OUTOPEN)
	var/target_state = TARGET_NONE

	/// Is an operation in progress? This basically makes /ui_act() syncronous
	var/operation_in_progress = FALSE


	/// Vent ID for all vents to link to on LateInitialize()
	var/vent_link_id
	/// All vents to control. Soft-refs only.
	var/list/vents = list()

	// Program vars
	/// Target pressure
	var/target_pressure

/obj/machinery/airlock_controller/Initialize(mapload)
	..()
	// We do all the work in there
	return INITIALIZE_HINT_LATELOAD

// Do setup of stuff here
/obj/machinery/airlock_controller/LateInitialize()
	for(var/obj/machinery/door/airlock/A as anything in GLOB.airlocks)
		if(A.id_tag == int_door_link_id)
			interior_doors += A.UID()
		if(A.id_tag == ext_door_link_id)
			exterior_doors += A.UID()

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


/obj/machinery/airlock_controller/attack_ghost(mob/user as mob)
	ui_interact(user)

/obj/machinery/airlock_controller/attack_ai(mob/user as mob)
	ui_interact(user)

/obj/machinery/airlock_controller/attack_hand(mob/user as mob)
	if(!user.IsAdvancedToolUser())
		return FALSE
	ui_interact(user)

/obj/machinery/airlock_controller/update_icon_state()
	if(powered(power_channel))
		if(state != target_state)
			icon_state = "airlock_control_process"
		else
			icon_state = "airlock_control_standby"
	else
		icon_state = "airlock_control_off"


/obj/machinery/airlock_controller/ui_act(action, params)
	if(..())
		return

	add_fingerprint(usr)

	if(operation_in_progress)
		return

	// Repeat the frontend check to make sure only allowed command are sent. You are only allowed to lock or cycle exterior if exterior is open
	// Vice versa for internal

	switch(action)
		if("abort")
			state = CONTROL_STATE_IDLE
			target_state = TARGET_NONE
		if("cycle_ext_door")
			// The reason these set state and dont just open the airlocks directly, is because this same topic is used by the cycler as well
			// It would be a major issue if they instantly opened before waiting for air to update
			state = CONTROL_STATE_IDLE
			target_state = TARGET_OUTOPEN
		if("cycle_int_door")
			state = CONTROL_STATE_IDLE
			target_state = TARGET_INOPEN
		if("force_ext")
			// Cannot force exterior if interior open
			if(internal_open)
				return

			operation_in_progress = TRUE
			if(external_open)
				set_airlocks(exterior_doors, FALSE)
			else
				set_airlocks(exterior_doors, TRUE)

			operation_in_progress = FALSE
			external_open = !external_open

		if("force_int")
			// Cannot force interior if exterior open
			if(external_open)
				return

			operation_in_progress = TRUE
			if(internal_open)
				set_airlocks(interior_doors, FALSE)
			else
				set_airlocks(interior_doors, TRUE)

			operation_in_progress = FALSE
			internal_open = !internal_open

	return TRUE


/obj/machinery/airlock_controller/proc/set_airlocks(list/airlocks, open = TRUE)
	// This logic makes sure that we dont finish until all airlocks are done
	var/list/current_run = list()
	var/list/current_queue = list()

	for(var/airlock_uid in airlocks)
		var/obj/machinery/door/airlock/A = locateUID(airlock_uid)
		if(QDELETED(A)) // It got qdeleted
			airlocks -= airlock_uid
			continue

		current_run += airlock_uid
		if(open)
			open_airlock_async(A, current_queue)
		else
			close_airlock_async(A, current_queue)

	UNTIL(length(current_run) == length(current_queue))

// These are async because the airlock animation thing sleeps
/obj/machinery/airlock_controller/proc/open_airlock_async(obj/machinery/door/airlock/A, list/Q)
	set waitfor = FALSE
	A.locked = FALSE
	A.open()
	A.locked = TRUE
	Q += 1

/obj/machinery/airlock_controller/proc/close_airlock_async(obj/machinery/door/airlock/A, list/Q)
	set waitfor = FALSE
	A.locked = FALSE
	A.close()
	A.locked = TRUE
	Q += 1

// Now for the pain
/obj/machinery/airlock_controller/process()
	#warn this needs to invoke and deploy a sleep, and have a catchup point
	if(operation_in_progress)
		return

	if(!state) //Idle
		if(target_state)
			switch(target_state)
				if(TARGET_INOPEN)
					target_pressure = ONE_ATMOSPHERE
				if(TARGET_OUTOPEN)
					target_pressure =  0

			// Prevent process() stacking with sleep locks
			operation_in_progress = TRUE
			begin_cycle()
		else
			//make sure to return to a sane idle state
			for(var/vent_uid in vents)
				var/obj/machinery/atmospherics/unary/vent_pump/V = locateUID(vent_uid)
				if(QDELETED(V))
					vents -= vent_uid
					continue

				if(V.on)
					V.on = FALSE
					V.update_icon()

	// Dont double-stack
	if(operation_in_progress)
		return

	if((state == CONTROL_STATE_PRESSURIZE || state == CONTROL_STATE_DEPRESSURIZE) && (internal_open || external_open))
		//the airlock will not allow itself to continue to cycle when any of the doors are forced open.
		state = CONTROL_STATE_IDLE
		target_state = TARGET_NONE

	switch(state)
		if(CONTROL_STATE_PREPARE)
			if(!(internal_open || external_open)) // Both closed
				var/chamber_pressure = round(return_air().return_pressure(), 0.1)

				if(chamber_pressure <= target_pressure)
					state = CONTROL_STATE_PRESSURIZE
					// Start pressurising
					for(var/vent_uid in vents)
						var/obj/machinery/atmospherics/unary/vent_pump/V = locateUID(vent_uid)
						if(QDELETED(V))
							vents -= vent_uid
							continue

						if(!V.on)
							V.on = TRUE
							V.releasing = TRUE
							V.external_pressure_bound = clamp(target_pressure, 0, ONE_ATMOSPHERE * 50)
							V.update_icon()

				else if(chamber_pressure > target_pressure)
					state = CONTROL_STATE_DEPRESSURIZE
					// Start depressurising
					for(var/vent_uid in vents)
						var/obj/machinery/atmospherics/unary/vent_pump/V = locateUID(vent_uid)
						if(QDELETED(V))
							vents -= vent_uid
							continue

						if(!V.on)
							V.on = TRUE
							V.releasing = FALSE
							V.external_pressure_bound = clamp(target_pressure, 0, ONE_ATMOSPHERE * 50)
							V.update_icon()

				//Check for vacuum - this is set after the pumps so the pumps are aiming for 0
				if(!target_pressure)
					target_pressure = ONE_ATMOSPHERE * 0.05

		if(CONTROL_STATE_PRESSURIZE)
			var/chamber_pressure = round(return_air().return_pressure(), 0.1)
			if(chamber_pressure >= (target_pressure * 0.95))
				operation_in_progress = TRUE
				finish_cycle()


		if(CONTROL_STATE_DEPRESSURIZE)
			var/chamber_pressure = round(return_air().return_pressure(), 0.1)
			if(chamber_pressure <= (target_pressure * 1.05))
				operation_in_progress = TRUE
				finish_cycle()


	return TRUE

/obj/machinery/airlock_controller/proc/begin_cycle()
	set waitfor = FALSE

	// Lock it down
	set_airlocks(interior_doors, FALSE)
	set_airlocks(exterior_doors, FALSE)
	state = CONTROL_STATE_PREPARE

	operation_in_progress = FALSE


/obj/machinery/airlock_controller/proc/finish_cycle()
	set waitfor = FALSE

	state_set_airlocks()

	// Stop pumping
	for(var/vent_uid in vents)
		var/obj/machinery/atmospherics/unary/vent_pump/V = locateUID(vent_uid)
		if(QDELETED(V))
			vents -= vent_uid
			continue

		if(V.on)
			V.on = FALSE
			V.update_icon()

	state = CONTROL_STATE_IDLE
	target_state = TARGET_NONE

	operation_in_progress = FALSE


/obj/machinery/airlock_controller/proc/state_set_airlocks()
	switch(target_state)
		if(TARGET_OUTOPEN)
			set_airlocks(interior_doors, FALSE)
			set_airlocks(exterior_doors, TRUE)
		if(TARGET_INOPEN)
			set_airlocks(interior_doors, TRUE)
			set_airlocks(exterior_doors, FALSE)
		if(TARGET_NONE)
			set_airlocks(interior_doors, FALSE)
			set_airlocks(exterior_doors, FALSE)

/* =============================== ACCESS CONTROLLER - No cycling required */
/obj/machinery/airlock_controller/access_controller
	icon_state = "access_control_standby"
	name = "airlock access controller"

/obj/machinery/airlock_controller/access_controller/update_icon_state()
	if(powered(power_channel))
		if(state != target_state)
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

	data["exterior_status"] = 1//program.memory["exterior_status"]
	data["interior_status"] = 1//program.memory["interior_status"]
	data["processing"] = 1//program.memory["processing"]

	return data


/* =============================== AIR CYCLER - Ensures internal pressure matches (just about) the void or the normal atmosphere */
/obj/machinery/airlock_controller/air_cycler/LateInitialize()
	..()
	for(var/obj/machinery/atmospherics/unary/vent_pump/V as anything in GLOB.all_vent_pumps)
		if(V.autolink_id == vent_link_id)
			vents += V.UID()

	if(!length(vents))
		stack_trace("[src] at [x],[y],[z] didnt setup any vents! Please double check the IDs!")


/obj/machinery/airlock_controller/air_cycler/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ExternalAirlockController", name, 470, 290, master_ui, state)
		ui.open()

/obj/machinery/airlock_controller/air_cycler/ui_data(mob/user)
	var/list/data = list()

	data["chamber_pressure"] = 1//round(program.memory["chamber_sensor_pressure"])
	data["exterior_status"] = 1//program.memory["exterior_status"]
	data["interior_status"] = 1//program.memory["interior_status"]
	data["processing"] = 1//program.memory["processing"]

	return data

