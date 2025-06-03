/obj/machinery/atmospherics/binary/passive_gate
	//Tries to achieve target pressure at output (like a normal pump) except
	//	Uses no power but can not transfer gases from a low pressure area to a high pressure area
	icon = 'icons/atmos/passive_gate.dmi'
	icon_state = "map"

	name = "passive gate"
	desc = "A one-way air valve that does not require power."

	can_unwrench = TRUE
	can_unwrench_while_on = FALSE

	target_pressure = ONE_ATMOSPHERE

	var/id = null

/obj/machinery/atmospherics/binary/passive_gate/can_be_pulled(user, grab_state, force, show_message)
	return FALSE

/obj/machinery/atmospherics/binary/passive_gate/CtrlClick(mob/living/user)
	if(can_use_shortcut(user))
		toggle(user)
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
	return ..()

/obj/machinery/atmospherics/binary/passive_gate/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This is a one-way regulator, allowing gas to flow only at a specific pressure and flow rate. If the light is green, gas is flowing.</span>"

/obj/machinery/atmospherics/binary/passive_gate/update_icon_state()
	icon_state = "[on ? "on" : "off"]"

/obj/machinery/atmospherics/binary/passive_gate/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, turn(dir, 180))
		add_underlay(T, node2, dir)

/obj/machinery/atmospherics/binary/passive_gate/process_atmos()
	if(!on)
		return 0

	var/output_starting_pressure = air2.return_pressure()
	var/input_starting_pressure = air1.return_pressure()

	if(output_starting_pressure >= min(target_pressure,input_starting_pressure - 10))
		//No need to pump gas if target is already reached or input pressure is too low
		//Need at least 10 KPa difference to overcome friction in the mechanism
		return 1

	if(target_pressure >= input_starting_pressure - 10)
		//Gas will not pump if the input pressure is lower than the target
		return 1

	//Calculate necessary moles to transfer using PV = nRT
	if((air1.total_moles() > 0) && (air1.temperature() > 0))
		var/pressure_delta = min(target_pressure - output_starting_pressure, (input_starting_pressure - output_starting_pressure) / 2)
		//Can not have a pressure delta that would cause output_pressure > input_pressure

		var/transfer_moles = pressure_delta * air2.volume / (air1.temperature() * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)
		air2.merge(removed)

		parent1.update = 1

		parent2.update = 1
	return 1

/obj/machinery/atmospherics/binary/passive_gate/attack_hand(mob/user)
	if(..())
		return

	if(!allowed(user))
		to_chat(user, "<span class='alert'>Access denied.</span>")
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/atmospherics/binary/passive_gate/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/binary/passive_gate/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/atmospherics/binary/passive_gate/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosPump", name)
		ui.open()

/obj/machinery/atmospherics/binary/passive_gate/ui_data(mob/user)
	var/list/data = list(
		"on" = on,
		"rate" = round(target_pressure),
		"max_rate" = MAX_OUTPUT_PRESSURE,
		"gas_unit" = "kPa",
		"step" = 10 // This is for the TGUI <NumberInput> step. It's here since multiple pumps share the same UI, but need different values.
	)
	return data

/obj/machinery/atmospherics/binary/passive_gate/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("power")
			toggle()
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			return TRUE

		if("max_rate")
			target_pressure = MAX_OUTPUT_PRESSURE
			. = TRUE

		if("min_rate")
			target_pressure = 0
			. = TRUE

		if("custom_rate")
			target_pressure = clamp(text2num(params["rate"]), 0 , MAX_OUTPUT_PRESSURE)
			. = TRUE
	if(.)
		investigate_log("was set to [target_pressure] kPa by [key_name(usr)]", INVESTIGATE_ATMOS)
