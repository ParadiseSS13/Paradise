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

/obj/machinery/atmospherics/binary/volume_pump
	icon = 'icons/atmos/volume_pump.dmi'
	icon_state = "map_off"

	name = "volumetric gas pump"
	desc = "A volumetric pump."

	can_unwrench = TRUE
	can_unwrench_while_on = FALSE

	var/transfer_rate = 200

	var/id = null

// So we can CtrlClick without triggering the anchored message.
/obj/machinery/atmospherics/binary/volume_pump/can_be_pulled(user, grab_state, force, show_message)
	return FALSE

/obj/machinery/atmospherics/binary/volume_pump/CtrlClick(mob/living/user)
	if(can_use_shortcut(user))
		toggle(user)
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
	return ..()

/obj/machinery/atmospherics/binary/volume_pump/AICtrlClick(mob/living/silicon/user)
	toggle(user)
	investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/binary/volume_pump/AltClick(mob/living/user)
	if(can_use_shortcut(user))
		set_max(user)
		investigate_log("was set to [target_pressure] kPa by [key_name(user)]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/binary/volume_pump/AIAltClick(mob/living/silicon/user)
	set_max(user)
	investigate_log("was set to [target_pressure] kPa by [key_name(user)]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/binary/volume_pump/on
	on = TRUE
	icon_state = "map_on"

/obj/machinery/atmospherics/binary/volume_pump/update_icon_state()
	if(!has_power())
		icon_state = "off"
	else
		icon_state = "[on ? "on" : "off"]"

/obj/machinery/atmospherics/binary/volume_pump/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, turn(dir, -180))
		add_underlay(T, node2, dir)

/obj/machinery/atmospherics/binary/volume_pump/process_atmos()
	if((stat & (NOPOWER|BROKEN)) || !on)
		return 0

	// Pump mechanism just won't do anything if the pressure is too high/too low
	var/input_starting_pressure = air1.return_pressure()
	var/output_starting_pressure = air2.return_pressure()

	if((input_starting_pressure < 0.01) || (output_starting_pressure > 9000))
		return 1

	var/transfer_ratio = max(1, transfer_rate/air1.volume)

	var/datum/gas_mixture/removed = air1.remove_ratio(transfer_ratio)

	air2.merge(removed)


	parent1.update = 1
	parent2.update = 1

	return 1

/obj/machinery/atmospherics/binary/volume_pump/attack_hand(mob/user)
	if(..())
		return

	if(!allowed(user))
		to_chat(user, "<span class='alert'>Access denied.</span>")
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/atmospherics/binary/volume_pump/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/binary/volume_pump/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/atmospherics/binary/volume_pump/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosPump", name)
		ui.open()

/obj/machinery/atmospherics/binary/volume_pump/ui_data(mob/user)
	var/list/data = list(
		"on" = on,
		"rate" = round(transfer_rate),
		"max_rate" = round(MAX_TRANSFER_RATE),
		"gas_unit" = "L/s",
		"step" = 1 // This is for the TGUI <NumberInput> step. It's here since multiple pumps share the same UI, but need different values.
	)
	return data

/obj/machinery/atmospherics/binary/volume_pump/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("power")
			toggle()
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			return TRUE

		if("max_rate")
			transfer_rate = MAX_TRANSFER_RATE
			. = TRUE

		if("min_rate")
			transfer_rate = 0
			. = TRUE

		if("custom_rate")
			transfer_rate = clamp(text2num(params["rate"]), 0 , MAX_TRANSFER_RATE)
			. = TRUE
	if(.)
		investigate_log("was set to [transfer_rate] L/s by [key_name(usr)]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/binary/volume_pump/power_change()
	if(!..())
		return
	update_icon()

/obj/machinery/atmospherics/binary/volume_pump/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(is_pen(used))
		rename_interactive(user, used)
		return ITEM_INTERACT_COMPLETE

	return ..()
