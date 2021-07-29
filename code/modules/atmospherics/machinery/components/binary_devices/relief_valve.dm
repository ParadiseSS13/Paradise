/obj/machinery/atmospherics/binary/relief_valve
	//Lets pressure equalize in one direction, when over a threshold
	icon = 'icons/atmos/relief_valve.dmi'
	icon_state = "map"

	name = "relief valve"
	desc = "A one-way pressure relief valve that does not require power"

	can_unwrench = 1

	var/on = 0
	var/relief_setting = ONE_ATMOSPHERE

	var/processing = 0

	var/id = null

/obj/machinery/atmospherics/binary/relief_valve/atmos_init()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/binary/relief_valve/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/atmospherics/binary/relief_valve/update_icon()
	..()
	if(!on)
		icon_state = "off"
	else
		if(!processing)
			icon_state = "on"
		else
			icon_state = "on_processing"

/obj/machinery/atmospherics/binary/relief_valve/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, turn(dir, 180))
		add_underlay(T, node2, dir)

/obj/machinery/atmospherics/binary/relief_valve/process_atmos()
	if(!on)
		return 0

	var/output_starting_pressure = air2.return_pressure()
	var/input_starting_pressure = air1.return_pressure()

	if(input_starting_pressure <= relief_setting || input_starting_pressure <= output_starting_pressure)
		//Don't process if the input pressure isn't over the relief setting or the output pressure
		processing = 0
		update_icon()
		return 1

	if((air1.total_moles() > 0) && (air1.temperature > 0))
		processing = 1
		update_icon()

		var/pressure_delta = input_starting_pressure - relief_setting - min(0, output_starting_pressure - relief_setting)
		//finds the functional pressure difference enforced by the relief setting

		var/transfer_moles = pressure_delta * air2.volume / (air1.temperature * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)
		air2.merge(removed)

		parent1.update = 1

		parent2.update = 1
	return 1

/obj/machinery/atmospherics/binary/relief_valve/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id,
		"device" = "AGP",
		"power" = on,
		"target_output" = relief_setting,
		"sigtype" = "status"
	)

	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	return 1

/obj/machinery/atmospherics/binary/relief_valve/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return 0

	var/old_on = on //for logging

	if("power" in signal.data)
		on = text2num(signal.data["power"])

	if("power_toggle" in signal.data)
		on = !on

	if("set_output_pressure" in signal.data)
		relief_setting = clamp(
			text2num(signal.data["set_output_pressure"]),
			0,
			ONE_ATMOSPHERE*50
		)

	if(on != old_on)
		investigate_log("was turned [on ? "on" : "off"] by a remote signal", "atmos")

	if("status" in signal.data)
		broadcast_status()
		return //do not update_icon

	broadcast_status()
	update_icon()
	return

/obj/machinery/atmospherics/binary/relief_valve/attack_hand(mob/user)
	if(..())
		return

	if(!allowed(user))
		to_chat(user, "<span class='alert'>Access denied.</span>")
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/atmospherics/binary/relief_valve/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/binary/relief_valve/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "AtmosPump", name, 310, 110, master_ui, state)
		ui.open()

/obj/machinery/atmospherics/binary/relief_valve/ui_data(mob/user)
	var/list/data = list(
		"on" = on,
		"rate" = round(relief_setting),
		"max_rate" = MAX_OUTPUT_PRESSURE,
		"gas_unit" = "kPa",
		"step" = 10 // This is for the TGUI <NumberInput> step. It's here since multiple pumps share the same UI, but need different values.
	)
	return data

/obj/machinery/atmospherics/binary/relief_valve/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("power")
			toggle()
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", "atmos")
			return TRUE

		if("max_target")
			relief_setting = MAX_OUTPUT_PRESSURE
			. = TRUE

		if("min_target")
			relief_setting = 0
			. = TRUE

		if("custom_target")
			relief_setting = clamp(text2num(params["target_pressure"]), 0 , MAX_OUTPUT_PRESSURE)
			. = TRUE
	if(.)
		investigate_log("was set to [relief_setting] kPa by [key_name(usr)]", "atmos")

/obj/machinery/atmospherics/binary/relief_valve/proc/toggle()
	if(powered())
		on = !on
		update_icon()

/obj/machinery/atmospherics/binary/relief_valve/attackby(obj/item/W, mob/user, params)
	if(!istype(W, /obj/item/wrench))
		return ..()
	if(on)
		to_chat(user, "<span class='alert'>You cannot unwrench this [src], turn it off first.</span>")
		return 1
	return ..()
