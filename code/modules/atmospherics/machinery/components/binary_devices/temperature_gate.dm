/obj/machinery/atmospherics/binary/temperature_gate

	name = "temperature gate"
	icon = 'icons/atmos/temperature_gate.dmi'
	icon_state = "map"

	name = "temperature gate"

	can_unwrench = TRUE
	can_unwrench_while_on = FALSE

	// if the temperature of the input mix is lower than this, gas will flow (or higher if inverted)
	var/target_temperature = 273 // 0C but rounded to nearest whole number

	// minimum allowed temperature - can't have anything under the coldest temperature, now can we?
	var/minimum_temperature = TCMB
	// maximum allowed temperature
	var/maximum_temperature = 4500

	var/inverted = FALSE

/obj/machinery/atmospherics/binary/temperature_gate/can_be_pulled(user, grab_state, force, show_message)
	return FALSE

/obj/machinery/atmospherics/binary/temperature_gate/CtrlClick(mob/living/user)
	if(can_use_shortcut(user))
		toggle(user)
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
	return ..()

/obj/machinery/atmospherics/binary/temperature_gate/examine(mob/user)
	. = ..()
	. += "<span class='notice'>A toggleable gate that compares the temperature on the interface with the incoming gas and allows it to pass if it is [inverted ? "is higher than" : "is lower than"] the set temperature.</span>"
	. += "<span class='notice'>It is currently set to [target_temperature] K and is [on ? "on" : "off"].</span>"

/obj/machinery/atmospherics/binary/temperature_gate/update_icon_state()
	icon_state = "[on ? "on" : "off"]"

/obj/machinery/atmospherics/binary/temperature_gate/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, turn(dir, 180))
		add_underlay(T, node2, dir)

/obj/machinery/atmospherics/binary/temperature_gate/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(inverted)
		to_chat(user, "<span class='notice'>You set [src] to normal operation mode.</span>")
		inverted = FALSE
	else
		to_chat(user, "<span class='notice'>You set [src] to inverted operation mode.</span>")
		inverted = TRUE


/obj/machinery/atmospherics/binary/temperature_gate/process_atmos()
	if((stat & (NOPOWER|BROKEN)) || !on)
		return 0

	var/input_temp = air1.temperature()
	var/allow_flow = FALSE

	if(inverted)
		if(input_temp > target_temperature)
			allow_flow = TRUE
	else
		if(input_temp < target_temperature)
			allow_flow = TRUE

	if(!allow_flow)
		return 1

	var/datum/gas_mixture/removed = air1.remove(air1.total_moles())
	if(removed && removed.total_moles() > 0)
		air2.merge(removed)

	parent1.update = 1
	parent2.update = 1

	return 1

/obj/machinery/atmospherics/binary/temperature_gate/attack_hand(mob/user)
	if(..())
		return

	if(!allowed(user))
		to_chat(user, "<span class='alert'>Access denied.</span>")
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/atmospherics/binary/temperature_gate/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/binary/temperature_gate/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/atmospherics/binary/temperature_gate/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosTemperatureGate", name)
		ui.open()

/obj/machinery/atmospherics/binary/temperature_gate/ui_data(mob/user)
	var/list/data = list(
		"on" = on,
		"inverted" = inverted,
		"temperature" = round(target_temperature),
		"max_temp" = maximum_temperature,
		"temp_unit" = "K",
		"step" = 10, // This is for the TGUI <NumberInput> step. It's here since multiple pumps share the same UI, but need different values.
	)
	return data

/obj/machinery/atmospherics/binary/temperature_gate/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("power")
			toggle()
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			return TRUE

		if("inverted")
			if(inverted)
				inverted = FALSE
			else
				inverted = TRUE

		if("max_temp")
			target_temperature = maximum_temperature
			. = TRUE

		if("min_temp")
			target_temperature = 0
			. = TRUE

		if("custom_temperature")
			target_temperature = clamp(text2num(params["temperature"]), 0 , maximum_temperature)
			. = TRUE

	if(.)
		investigate_log("was set to [target_temperature] K by [key_name(usr)]", INVESTIGATE_ATMOS)

