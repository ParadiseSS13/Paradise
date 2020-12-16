/*
Every cycle, the pump uses the air in air_in to try and make air_out the perfect pressure.

node1, air1, network1 correspond to input
node2, air2, network2 correspond to output

Thus, the two variables affect pump operation are set in New():
	air1.volume
		This is the volume of gas available to the pump that may be transfered to the output
	air2.volume
		Higher quantities of this cause more air to be perfected later
			but overall network volume is also increased as this increases...
*/

/obj/machinery/atmospherics/binary/pump
	icon = 'icons/atmos/pump.dmi'
	icon_state = "map_off"

	name = "gas pump"
	desc = "A pump"

	can_unwrench = 1

	var/on = 0
	var/target_pressure = ONE_ATMOSPHERE

	var/id = null

/obj/machinery/atmospherics/binary/pump/CtrlClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user) && !issilicon(usr))
		return
	if(!ishuman(usr) && !issilicon(usr))
		return
	toggle()
	return ..()

/obj/machinery/atmospherics/binary/pump/AICtrlClick()
	toggle()
	return ..()

/obj/machinery/atmospherics/binary/pump/AltClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user) && !issilicon(usr))
		return
	if(!ishuman(usr) && !issilicon(usr))
		return
	set_max()
	return

/obj/machinery/atmospherics/binary/pump/AIAltClick()
	set_max()
	return ..()

/obj/machinery/atmospherics/binary/pump/proc/toggle()
	if(powered())
		on = !on
		update_icon()

/obj/machinery/atmospherics/binary/pump/proc/set_max()
	if(powered())
		target_pressure = MAX_OUTPUT_PRESSURE
		update_icon()

/obj/machinery/atmospherics/binary/pump/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/atmospherics/binary/pump/on
	icon_state = "map_on"
	on = 1

/obj/machinery/atmospherics/binary/pump/update_icon()
	..()

	if(!powered())
		icon_state = "off"
	else
		icon_state = "[on ? "on" : "off"]"

/obj/machinery/atmospherics/binary/pump/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, turn(dir, -180))
		add_underlay(T, node2, dir)

/obj/machinery/atmospherics/binary/pump/process_atmos()
	..()
	if((stat & (NOPOWER|BROKEN)) || !on)
		return 0

	var/output_starting_pressure = air2.return_pressure()

	if( (target_pressure - output_starting_pressure) < 0.01)
		//No need to pump gas if target is already reached!
		return 1

	//Calculate necessary moles to transfer using PV=nRT
	if((air1.total_moles() > 0) && (air1.temperature>0))
		var/pressure_delta = target_pressure - output_starting_pressure
		var/transfer_moles = pressure_delta*air2.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)
		air2.merge(removed)

		parent1.update = 1

		parent2.update = 1
	return 1

/obj/machinery/atmospherics/binary/pump/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id,
		"device" = "AGP",
		"power" = on,
		"target_output" = target_pressure,
		"sigtype" = "status"
	)

	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)
	return 1

/obj/machinery/atmospherics/binary/pump/atmos_init()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/binary/pump/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return 0

	var/old_on = on //for logging

	if(signal.data["power"])
		on = text2num(signal.data["power"])

	if(signal.data["power_toggle"])
		on = !on

	if(signal.data["set_output_pressure"])
		target_pressure = between(
			0,
			text2num(signal.data["set_output_pressure"]),
			ONE_ATMOSPHERE*50
		)

	if(on != old_on)
		investigate_log("was turned [on ? "on" : "off"] by a remote signal", "atmos")

	if(signal.data["status"])
		spawn(2)
			broadcast_status()
		return //do not update_icon

	spawn(2)
		broadcast_status()
	update_icon()
	return

/obj/machinery/atmospherics/binary/pump/attack_hand(mob/user)
	if(..())
		return

	if(!allowed(user))
		to_chat(user, "<span class='alert'>Access denied.</span>")
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/atmospherics/binary/pump/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/binary/pump/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "AtmosPump", name, 310, 110, master_ui, state)
		ui.open()

/obj/machinery/atmospherics/binary/pump/ui_data(mob/user)
	var/list/data = list(
		"on" = on,
		"rate" = round(target_pressure),
		"max_rate" = MAX_OUTPUT_PRESSURE,
		"gas_unit" = "kPa",
		"step" = 10 // This is for the TGUI <NumberInput> step. It's here since multiple pumps share the same UI, but need different values.
	)
	return data

/obj/machinery/atmospherics/binary/pump/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("power")
			toggle()
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", "atmos")
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
		investigate_log("was set to [target_pressure] kPa by [key_name(usr)]", "atmos")

/obj/machinery/atmospherics/binary/pump/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/binary/pump/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pen))
		rename_interactive(user, W)
		return
	else if(!istype(W, /obj/item/wrench))
		return ..()
	if(!(stat & NOPOWER) && on)
		to_chat(user, "<span class='alert'>You cannot unwrench this [src], turn it off first.</span>")
		return 1
	return ..()
