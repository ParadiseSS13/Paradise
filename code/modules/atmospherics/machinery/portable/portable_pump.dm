
/// The maximum `target_pressure` you can set on the pump.
#define MAX_TARGET_PRESSURE 45 * ONE_ATMOSPHERE
/// The pump will be siphoning gas.
#define DIRECTION_IN 0
/// The pump will be pumping gas out.
#define DIRECTION_OUT 1

/obj/machinery/atmospherics/portable/pump
	name = "portable air pump"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "ppump:0"
	base_icon_state = "ppump"
	var/base_attachment_icon_state = "ppump"
	density = TRUE
	volume = 1000
	/// The direction the pump is operating in. This should be either `DIRECTION_IN` or `DIRECTION_OUT`.
	var/direction = DIRECTION_IN
	/// The desired pressure the pump should be outputting, either into the atmosphere, or into a holding tank.
	target_pressure = 101.325
	resistance_flags = NONE

/obj/machinery/atmospherics/portable/pump/Initialize(mapload)
	. = ..()
	// Fill with normal air.
	air_contents.set_oxygen(MAX_TARGET_PRESSURE * O2STANDARD * volume / (T20C * R_IDEAL_GAS_EQUATION))
	air_contents.set_nitrogen(MAX_TARGET_PRESSURE * N2STANDARD * volume / (T20C * R_IDEAL_GAS_EQUATION))

/obj/machinery/atmospherics/portable/pump/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Invaluable for filling air in a room rapidly after a breach repair. The internal gas container can be filled by \
			connecting it to a connector port, you're unable to have it both connected, and on at the same time. \
			[src] can pump the air in (sucking) or out (blowing), at a specific target pressure. \
			A tank of gas can also be attached to the air pump, allowing you to fill or empty the tank, via the internal one.</span>"

/obj/machinery/atmospherics/portable/pump/update_icon_state()
	icon_state = "[base_icon_state]:[on]"

/obj/machinery/atmospherics/portable/pump/update_overlays()
	. = ..()
	if(holding_tank)
		. += "[base_attachment_icon_state]-open"
	if(connected_port)
		. += "[base_attachment_icon_state]-connector"

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
		var/datum/milla_safe/portable_pump_process/milla = new()
		milla.invoke_async(src)

/datum/milla_safe/portable_pump_process

/datum/milla_safe/portable_pump_process/on_run(obj/machinery/atmospherics/portable/pump/pump)
	var/datum/gas_mixture/environment
	if(pump.holding_tank)
		environment = pump.holding_tank.air_contents
	else
		var/turf/T = get_turf(pump)
		environment = get_turf_air(T)
	if(pump.direction == DIRECTION_OUT)
		var/pressure_delta = pump.target_pressure - environment.return_pressure()
		//Can not have a pressure delta that would cause environment pressure > tank pressure

		var/transfer_moles = 0
		if(pump.air_contents.temperature() > 0)
			transfer_moles = pressure_delta*environment.volume/(pump.air_contents.temperature() * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = pump.air_contents.remove(transfer_moles)

			environment.merge(removed)
	else
		var/pressure_delta = pump.target_pressure - pump.air_contents.return_pressure()
		//Can not have a pressure delta that would cause environment pressure > tank pressure

		var/transfer_moles = 0
		if(environment.temperature() > 0)
			transfer_moles = pressure_delta*pump.air_contents.volume/(environment.temperature() * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed
			removed = environment.remove(transfer_moles)

			pump.air_contents.merge(removed)

/obj/machinery/atmospherics/portable/pump/return_obj_air()
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
			investigate_log("[key_name(user)] started a transfer into [holding_tank].<br>", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/portable/pump/attack_ai(mob/user)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/atmospherics/portable/pump/attack_ghost(mob/user)
	if(..())
		return
	return attack_hand(user)

/obj/machinery/atmospherics/portable/pump/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/portable/pump/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/atmospherics/portable/pump/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortablePump", "Portable Pump")
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

/obj/machinery/atmospherics/portable/pump/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return

	switch(action)
		if("power")
			if(connected_port)
				to_chat(ui.user, "<span class='warning'>[src] fails to turn on, the port is covered!</span>")
				return
			on = !on
			if(on && direction == DIRECTION_OUT)
				investigate_log("[key_name(usr)] started a transfer into [holding_tank].<br>", INVESTIGATE_ATMOS)
			update_icon()
			return TRUE

		if("set_direction")
			if(text2num(params["direction"]) == DIRECTION_IN)
				direction = DIRECTION_IN
			else
				direction = DIRECTION_OUT
			if(on && holding_tank)
				investigate_log("[key_name(usr)] started a transfer into [holding_tank].<br>", INVESTIGATE_ATMOS)
			update_icon()
			return TRUE

		if("remove_tank")
			replace_tank(ui.user, TRUE)
			update_icon()
			return TRUE

		if("set_pressure")
			target_pressure = clamp(text2num(params["pressure"]), 0, MAX_TARGET_PRESSURE)
			return TRUE

	add_fingerprint(usr)

/obj/machinery/atmospherics/portable/pump/big
	name = "large portable air pump"
	icon_state = "ppump_big:0"
	base_icon_state = "ppump_big"
	base_attachment_icon_state = "ppump_big"
	volume = 5000

/obj/machinery/atmospherics/portable/pump/big/examine(mob/user)
	. = ..()
	. += "<br><span class='notice'>This one is quite large, enabling it to hold more air.</span>"

/obj/machinery/atmospherics/portable/pump/bluespace
	name = "bluespace portable air pump"
	icon_state = "ppump_bs:0"
	base_icon_state = "ppump_bs"
	base_attachment_icon_state = "ppump_big"
	volume = 25000

/obj/machinery/atmospherics/portable/pump/bluespace/examine(mob/user)
	. = ..()
	. += "<br><span class='notice'>This one is not only large, but made of exotic materials, and uses bluespace technology to hold even more air.</span>"

/obj/machinery/atmospherics/portable/pump/bluespace/update_icon_state()
	if(on && direction == DIRECTION_IN)
		icon_state = "[base_icon_state]:[on]-r"
	else
		icon_state = "[base_icon_state]:[on]"

/obj/machinery/atmospherics/portable/pump/Move(NewLoc, direct)
	. = ..()
	if(!.)
		return
	playsound(loc, pick('sound/items/cartwheel1.ogg', 'sound/items/cartwheel2.ogg'), 100, TRUE, ignore_walls = FALSE)

#undef MAX_TARGET_PRESSURE
#undef DIRECTION_IN
#undef DIRECTION_OUT
