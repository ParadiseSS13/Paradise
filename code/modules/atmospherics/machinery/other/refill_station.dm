/// The maximum `target_pressure` you can set on the pump. Equates to about 1013.25 kPa.
#define MAX_TARGET_PRESSURE 10 * ONE_ATMOSPHERE

/obj/machinery/atmospherics/portable/pump/refill_station
	name = "refill station"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "psiphon:0"
	anchored = TRUE
	density = FALSE
	volume = 50
	/// The desired pressure the pump should be outputting into a holding tank.
	target_pressure = 101.325
	resistance_flags = NONE
	/// Is the refill station ID locked?
	var/id_locked = FALSE

/obj/machinery/atmospherics/portable/pump/refill_station/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The Nanotrasen standard [src] is a vital piece of equipment for \
	ensuring a multi-species crew. By providing an easy-to-access source of refillable air of \
	various mixes, Nanotrasen aims to ensure worker productivity through the provision of breathable \
	atmospherics to their crew.</span>"

/obj/machinery/atmospherics/portable/pump/refill_station/update_icon_state()
	icon_state = "psiphon:[on]"

/obj/machinery/atmospherics/portable/pump/refill_station/process_atmos()
	..()
	var/datum/milla_safe/refill_station_process/milla = new()
	milla.invoke_async(src)

/obj/machinery/atmospherics/portable/pump/refill_station/wrench_act(mob/user, obj/item/I)
	return

/datum/milla_safe/refill_station_process

/datum/milla_safe/refill_station_process/on_run(obj/machinery/atmospherics/portable/pump/refill_station/refill_station)
	if(refill_station.on)
		var/datum/gas_mixture/environment
		if(!refill_station.holding_tank)
			return
		environment = refill_station.holding_tank.air_contents

		var/pressure_delta = refill_station.target_pressure - environment.return_pressure()
		//Can not have a pressure delta that would cause environment pressure > tank pressure

		var/transfer_moles = 0
		if(refill_station.air_contents.temperature() > 0)
			transfer_moles = pressure_delta*environment.volume/(refill_station.air_contents.temperature() * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = refill_station.air_contents.remove(transfer_moles)
			environment.merge(removed)

/obj/machinery/atmospherics/portable/pump/refill_station/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RefillStation", "Refill Station")
		ui.open()

/obj/machinery/atmospherics/portable/pump/refill_station/ui_data(mob/user)
	var/list/data = list(
		"on" = on,
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

/obj/machinery/atmospherics/portable/pump/refill_station/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return

	switch(action)
		if("power")
			if(connected_port)
				to_chat(ui.user, "<span class='warning'>[src] fails to turn on, the port is covered!</span>")
				return
			on = !on
			investigate_log("[key_name(usr)] started a transfer into [holding_tank].<br>", "atmos")
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

#undef MAX_TARGET_PRESSURE
