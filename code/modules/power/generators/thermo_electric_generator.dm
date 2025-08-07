/obj/machinery/power/teg
	name = "thermoelectric generator"
	desc = "It's a high efficiency thermoelectric generator."
	icon_state = "teg"
	anchored = FALSE
	density = TRUE

	var/obj/machinery/atmospherics/binary/circulator/cold_circ
	var/obj/machinery/atmospherics/binary/circulator/hot_circ

	var/cold_dir = WEST
	var/hot_dir = EAST

	var/lastgen = 0
	var/lastgenlev = -1
	var/lastcirc = "00"

	var/light_range_on = 1
	var/light_power_on = 0.1 //just dont want it to be culled by byond.

/obj/machinery/power/teg/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_DESC)
	connect()

/obj/machinery/power/teg/update_desc()
	. = ..()
	desc = initial(desc) + " Its cold circulator is located on the [dir2text(cold_dir)] side, and its heat circulator is located on the [dir2text(hot_dir)] side."

/obj/machinery/power/teg/Destroy()
	disconnect()
	return ..()

/obj/machinery/power/teg/proc/disconnect()
	if(cold_circ)
		cold_circ.generator = null
	if(hot_circ)
		hot_circ.generator = null
	if(powernet)
		disconnect_from_network()

/obj/machinery/power/teg/proc/connect()
	connect_to_network()

	cold_circ = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src, cold_dir)
	hot_circ = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src, hot_dir)

	if(cold_circ?.side == cold_dir)
		cold_circ.generator = src
		cold_circ.update_icon()
	else
		cold_circ = null

	if(hot_circ?.side == hot_dir)
		hot_circ.generator = src
		hot_circ.update_icon()
	else
		hot_circ = null

	power_change()
	update_icon()
	updateDialog()

/obj/machinery/power/teg/power_change()
	. = ..()
	if(!anchored)
		stat |= NOPOWER
	if((stat & (BROKEN|NOPOWER)))
		set_light(0)
	else
		set_light(light_range_on, light_power_on)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/power/teg/update_overlays()
	. = ..()
	if(stat & (NOPOWER|BROKEN))
		return

	if(lastgenlev != 0)
		. += "teg-op[lastgenlev]"
		if(light)
			. += emissive_appearance(icon, "teg-op[lastgenlev]")

	. += "teg-oc[lastcirc]"
	if(light)
		. += emissive_appearance(icon, "teg-oc[lastcirc]")

/obj/machinery/power/teg/process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(!cold_circ || !hot_circ)
		return

	lastgen = 0

	if(powernet)

		//log_debug("cold_circ and hot_circ pass")

		var/datum/gas_mixture/cold_air = cold_circ.return_transfer_air()
		var/datum/gas_mixture/hot_air = hot_circ.return_transfer_air()

		//log_debug("hot_air = [hot_air]; cold_air = [cold_air];")

		if(cold_air && hot_air)

			//log_debug("hot_air = [hot_air] temperature = [hot_air.temperature()]; cold_air = [cold_air] temperature = [hot_air.temperature()];")

			//log_debug("coldair and hotair pass")
			var/cold_air_heat_capacity = cold_air.heat_capacity()
			var/hot_air_heat_capacity = hot_air.heat_capacity()

			var/delta_temperature = hot_air.temperature() - cold_air.temperature()

			//log_debug("delta_temperature = [delta_temperature]; cold_air_heat_capacity = [cold_air_heat_capacity]; hot_air_heat_capacity = [hot_air_heat_capacity]")

			if(delta_temperature > 0 && cold_air_heat_capacity > 0 && hot_air_heat_capacity > 0)
				var/efficiency = 0.65

				var/energy_transfer = delta_temperature * hot_air_heat_capacity * cold_air_heat_capacity / (hot_air_heat_capacity + cold_air_heat_capacity)

				var/heat = energy_transfer * (1 - efficiency)
				lastgen = energy_transfer * efficiency

				//log_debug("lastgen = [lastgen]; heat = [heat]; delta_temperature = [delta_temperature]; hot_air_heat_capacity = [hot_air_heat_capacity]; cold_air_heat_capacity = [cold_air_heat_capacity];")

				hot_air.set_temperature(hot_air.temperature() - energy_transfer / hot_air_heat_capacity)
				cold_air.set_temperature(cold_air.temperature() + heat / cold_air_heat_capacity)

				//log_debug("POWER: [lastgen] W generated at [efficiency * 100]% efficiency and sinks sizes [cold_air_heat_capacity], [hot_air_heat_capacity]")

				produce_direct_power(lastgen)
		// update icon overlays only if displayed level has changed

		if(hot_air)
			var/datum/gas_mixture/hot_circ_air1 = hot_circ.get_outlet_air()
			hot_circ_air1.merge(hot_air)

		if(cold_air)
			var/datum/gas_mixture/cold_circ_air1 = cold_circ.get_outlet_air()
			cold_circ_air1.merge(cold_air)

	var/genlev = max(0, min( round(11 * lastgen / 100000), 11))
	var/circ = "[cold_circ && cold_circ.last_pressure_delta > 0 ? "1" : "0"][hot_circ && hot_circ.last_pressure_delta > 0 ? "1" : "0"]"
	if((genlev != lastgenlev) || (circ != lastcirc))
		lastgenlev = genlev
		lastcirc = circ
		update_icon(UPDATE_OVERLAYS)

	updateDialog()

/obj/machinery/power/teg/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/power/teg/attack_ghost(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	ui_interact(user)

/obj/machinery/power/teg/attack_hand(mob/user)
	if(..())
		user << browse(null, "window=teg")
		return
	ui_interact(user)

/obj/machinery/power/teg/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(cold_dir == WEST)
		cold_dir = EAST
		hot_dir = WEST
	else if(cold_dir == NORTH)
		cold_dir = SOUTH
		hot_dir = NORTH
	else if(cold_dir == EAST)
		cold_dir = WEST
		hot_dir = EAST
	else
		cold_dir = NORTH
		hot_dir = SOUTH
	connect()
	to_chat(user, "<span class='notice'>You reverse the generator's circulator settings. The cold circulator is now on the [dir2text(cold_dir)] side, and the heat circulator is now on the [dir2text(hot_dir)] side.</span>")
	update_appearance(UPDATE_DESC)

/obj/machinery/power/teg/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!default_unfasten_wrench(user, I, 0))
		return
	if(!anchored)
		disconnect()
	else
		connect()

/obj/machinery/power/teg/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/power/teg/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TEG",  name)
		ui.open()

/obj/machinery/power/teg/ui_data(mob/user)
	var/list/data = list()
	if(!powernet)
		data["error"] = "Unable to connect to the power network!"
	else if(cold_circ && hot_circ)
		var/datum/gas_mixture/cold_circ_air1 = cold_circ.get_outlet_air()
		var/datum/gas_mixture/cold_circ_air2 = cold_circ.get_inlet_air()
		var/datum/gas_mixture/hot_circ_air1 = hot_circ.get_outlet_air()
		var/datum/gas_mixture/hot_circ_air2 = hot_circ.get_inlet_air()

		data["cold_dir"] = dir2text(cold_dir)
		data["hot_dir"] = dir2text(hot_dir)
		data["output_power"] = round(lastgen)
		// Temps are K, pressures are kPa, power is W
		data["cold_inlet_temp"] = round(cold_circ_air2.temperature(), 0.1)
		data["hot_inlet_temp"] = round(hot_circ_air2.temperature(), 0.1)
		data["cold_outlet_temp"] = round(cold_circ_air1.temperature(), 0.1)
		data["hot_outlet_temp"] = round(hot_circ_air1.temperature(), 0.1)
		data["cold_delta_temp"] = data["cold_outlet_temp"] - data["cold_inlet_temp"]
		data["cold_inlet_pressure"] = round(cold_circ_air2.return_pressure(), 0.1)
		data["hot_inlet_pressure"] = round(hot_circ_air2.return_pressure(), 0.1)
		data["cold_outlet_pressure"] = round(cold_circ_air1.return_pressure(), 0.1)
		data["hot_outlet_pressure"] = round(hot_circ_air1.return_pressure(), 0.1)
		data["warning_switched"] = (data["cold_inlet_temp"] > data["hot_inlet_temp"])
		data["warning_cold_pressure"] = (data["cold_inlet_pressure"] < 1000)
		data["warning_hot_pressure"] = (data["hot_inlet_pressure"] < 1000)
	else
		data["error"] = "Unable to locate all parts!"
	return data

/obj/machinery/power/teg/ui_act(action, params)
	if(..())
		return
	if(action == "check")
		if(!powernet || !cold_circ || !hot_circ)
			connect()
			return TRUE
