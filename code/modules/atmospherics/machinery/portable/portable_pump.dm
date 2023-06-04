
/// The maximum `target_pressure` you can set on the pump. Equates to about 1013.25 kPa.
#define MAX_TARGET_PRESSURE 10 * ONE_ATMOSPHERE
/// The pump will be siphoning gas.
#define DIRECTION_IN 0
/// The pump will be pumping gas out.
#define DIRECTION_OUT 1

/obj/machinery/atmospherics/portable/pump
	name = "Portable Air Pump"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "psiphon:0"
	density = TRUE
	volume = 1000
	/// The direction the pump is operating in. This should be either `DIRECTION_IN` or `DIRECTION_OUT`.
	var/direction = DIRECTION_IN
	/// The desired pressure the pump should be outputting, either into the atmosphere, or into a holding tank.
	target_pressure = 101.325

/obj/machinery/atmospherics/portable/pump/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Invaluable for filling air in a room rapidly after a breach repair. The internal gas container can be filled by \
			connecting it to a connector port. The pump can pump the air in (sucking) or out (blowing), at a specific target pressure. The powercell inside can be \
			replaced by using a screwdriver, and then adding a new cell. A tank of gas can also be attached to the air pump.</span>"

/obj/machinery/atmospherics/portable/pump/update_icon_state()
	icon_state = "psiphon:[on]"

/obj/machinery/atmospherics/portable/pump/update_overlays()
	. = ..()
	if(holding_tank)
		. += "siphon-open"
	if(connected_port)
		. += "siphon-connector"

/obj/machinery/atmospherics/portable/pump/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	if(prob(50/severity))
		on = !on

	if(prob(100/severity))
		direction = !direction

	target_pressure = rand(0,1300)
	update_icon()

	..(severity)

/obj/machinery/atmospherics/portable/pump/process_atmos()
	..()
	if(on)
		var/datum/gas_mixture/environment
		if(holding_tank)
			environment = holding_tank.air_contents
		else
			environment = loc.return_air()
		if(direction == DIRECTION_OUT)
			var/pressure_delta = target_pressure - environment.return_pressure()
			//Can not have a pressure delta that would cause environment pressure > tank pressure

			var/transfer_moles = 0
			if(air_contents.temperature > 0)
				transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

				//Actually transfer the gas
				var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

				if(holding_tank)
					environment.merge(removed)
				else
					loc.assume_air(removed)
					air_update_turf()
		else
			var/pressure_delta = target_pressure - air_contents.return_pressure()
			//Can not have a pressure delta that would cause environment pressure > tank pressure

			var/transfer_moles = 0
			if(environment.temperature > 0)
				transfer_moles = pressure_delta*air_contents.volume/(environment.temperature * R_IDEAL_GAS_EQUATION)

				//Actually transfer the gas
				var/datum/gas_mixture/removed
				if(holding_tank)
					removed = environment.remove(transfer_moles)
				else
					removed = loc.remove_air(transfer_moles)
					air_update_turf()

				air_contents.merge(removed)

	return

/obj/machinery/atmospherics/portable/pump/return_air()
	RETURN_TYPE(/datum/gas_mixture)
	return air_contents

/obj/machinery/atmospherics/portable/pump/replace_tank(mob/living/user, close_valve)
	. = ..()
	if(.)
		if(close_valve)
			if(on)
				on = FALSE
				update_icon()
		else if(on && holding_tank && direction == DIRECTION_OUT)
			investigate_log("[key_name(user)] started a transfer into [holding_tank].<br>", "atmos")

/obj/machinery/atmospherics/portable/pump/attack_ai(mob/user)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/atmospherics/portable/pump/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/atmospherics/portable/pump/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/portable/pump/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "PortablePump", "Portable Pump", 434, 377, master_ui, state)
		ui.open()

/obj/machinery/atmospherics/portable/pump/ui_data(mob/user)
	var/list/data = list(
		"on" = on,
		"direction" = direction,
		"port_connected" = connected_port ? TRUE : FALSE,
		"max_target_pressure" = MAX_TARGET_PRESSURE,
		"target_pressure" = round(target_pressure, 0.001),
		"tank_pressure" = air_contents.return_pressure() > 0 ? round(air_contents.return_pressure(), 0.001) : 0
	)
	if(holding_tank)
		data["has_holding_tank"] = TRUE
		data["holding_tank"] = list("name" = holding_tank.name, "tank_pressure" = holding_tank.air_contents.return_pressure() > 0 ? round(holding_tank.air_contents.return_pressure(), 0.001) : 0)
	else
		data["has_holding_tank"] = FALSE

	return data

/obj/machinery/atmospherics/portable/pump/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("power")
			on = !on
			if(on && direction == DIRECTION_OUT)
				investigate_log("[key_name(usr)] started a transfer into [holding_tank].<br>", "atmos")
			update_icon()
			return TRUE

		if("set_direction")
			if(text2num(params["direction"]) == DIRECTION_IN)
				direction = DIRECTION_IN
			else
				direction = DIRECTION_OUT
			if(on && holding_tank)
				investigate_log("[key_name(usr)] started a transfer into [holding_tank].<br>", "atmos")
			return TRUE

		if("remove_tank")
			if(holding_tank)
				on = FALSE
				holding_tank.forceMove(get_turf(src))
				holding_tank = null
			update_icon()
			return TRUE

		if("set_pressure")
			target_pressure = clamp(text2num(params["pressure"]), 0, MAX_TARGET_PRESSURE)
			return TRUE

	add_fingerprint(usr)

#undef MAX_TARGET_PRESSURE
#undef DIRECTION_IN
#undef DIRECTION_OUT
