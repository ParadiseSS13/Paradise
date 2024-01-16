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

	can_unwrench = TRUE

	target_pressure = ONE_ATMOSPHERE

	var/id = null

/obj/machinery/atmospherics/binary/pump/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This moves gas from one pipe to another. A higher target pressure demands more energy. The side with the red end is the output.</span>"

// So we can CtrlClick without triggering the anchored message.
/obj/machinery/atmospherics/binary/pump/can_be_pulled(user, grab_state, force, show_message)
	return FALSE

/obj/machinery/atmospherics/binary/pump/CtrlClick(mob/living/user)
	if(can_use_shortcut(user))
		toggle(user)
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", "atmos")
	return ..()

/obj/machinery/atmospherics/binary/pump/AICtrlClick(mob/living/silicon/user)
	toggle(user)
	investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", "atmos")

/obj/machinery/atmospherics/binary/pump/AltClick(mob/living/user)
	if(can_use_shortcut(user))
		set_max(user)
		investigate_log("was set to [target_pressure] kPa by [key_name(user)]", "atmos")

/obj/machinery/atmospherics/binary/pump/AIAltClick(mob/living/silicon/user)
	set_max(user)
	investigate_log("was set to [target_pressure] kPa by [key_name(user)]", "atmos")

/obj/machinery/atmospherics/binary/pump/on
	icon_state = "map_on"
	on = TRUE

/obj/machinery/atmospherics/binary/pump/update_icon_state()
	if(!has_power())
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

	if((target_pressure - output_starting_pressure) < 0.01)
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
	if(!..())
		return
	update_icon()

/obj/machinery/atmospherics/binary/pump/attackby(obj/item/W, mob/user, params)
	if(is_pen(W))
		rename_interactive(user, W)
		return
	else if(!istype(W, /obj/item/wrench))
		return ..()
	if(!(stat & NOPOWER) && on)
		to_chat(user, "<span class='alert'>You cannot unwrench this [src], turn it off first.</span>")
		return 1
	return ..()
