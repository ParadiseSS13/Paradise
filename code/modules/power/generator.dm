/obj/machinery/power/generator
	name = "thermoelectric generator"
	desc = "It's a high efficiency thermoelectric generator."
	icon_state = "teg"
	anchored = 0
	density = 1
	use_power = NO_POWER_USE

	var/obj/machinery/atmospherics/binary/circulator/cold_circ
	var/obj/machinery/atmospherics/binary/circulator/hot_circ

	var/cold_dir = WEST
	var/hot_dir = EAST

	var/lastgen = 0
	var/lastgenlev = -1
	var/lastcirc = "00"

/obj/machinery/power/generator/New()
	..()
	update_desc()

/obj/machinery/power/generator/proc/update_desc()
	desc = initial(desc) + " Its cold circulator is located on the [dir2text(cold_dir)] side, and its heat circulator is located on the [dir2text(hot_dir)] side."

/obj/machinery/power/generator/Destroy()
	disconnect()
	return ..()

/obj/machinery/power/generator/proc/disconnect()
	if(cold_circ)
		cold_circ.generator = null
	if(hot_circ)
		hot_circ.generator = null
	if(powernet)
		disconnect_from_network()

/obj/machinery/power/generator/Initialize()
	..()
	connect()

/obj/machinery/power/generator/proc/connect()
	connect_to_network()

	var/obj/machinery/atmospherics/binary/circulator/circpath = /obj/machinery/atmospherics/binary/circulator
	cold_circ = locate(circpath) in get_step(src, cold_dir)
	hot_circ = locate(circpath) in get_step(src, hot_dir)

	if(cold_circ && cold_circ.side == cold_dir)
		cold_circ.generator = src
		cold_circ.update_icon()
	else
		cold_circ = null

	if(hot_circ && hot_circ.side == hot_dir)
		hot_circ.generator = src
		hot_circ.update_icon()
	else
		hot_circ = null

	power_change()
	update_icon()
	updateDialog()

/obj/machinery/power/generator/power_change()
	if(!anchored)
		stat |= NOPOWER
	else
		..()

/obj/machinery/power/generator/update_icon()
	if(stat & (NOPOWER|BROKEN))
		overlays.Cut()
	else
		overlays.Cut()

		if(lastgenlev != 0)
			overlays += image('icons/obj/power.dmi', "teg-op[lastgenlev]")

		overlays += image('icons/obj/power.dmi', "teg-oc[lastcirc]")

/obj/machinery/power/generator/process()
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

			//log_debug("hot_air = [hot_air] temperature = [hot_air.temperature]; cold_air = [cold_air] temperature = [hot_air.temperature];")

			//log_debug("coldair and hotair pass")
			var/cold_air_heat_capacity = cold_air.heat_capacity()
			var/hot_air_heat_capacity = hot_air.heat_capacity()

			var/delta_temperature = hot_air.temperature - cold_air.temperature

			//log_debug("delta_temperature = [delta_temperature]; cold_air_heat_capacity = [cold_air_heat_capacity]; hot_air_heat_capacity = [hot_air_heat_capacity]")

			if(delta_temperature > 0 && cold_air_heat_capacity > 0 && hot_air_heat_capacity > 0)
				var/efficiency = 0.65

				var/energy_transfer = delta_temperature * hot_air_heat_capacity * cold_air_heat_capacity / (hot_air_heat_capacity + cold_air_heat_capacity)

				var/heat = energy_transfer * (1 - efficiency)
				lastgen = energy_transfer * efficiency

				//log_debug("lastgen = [lastgen]; heat = [heat]; delta_temperature = [delta_temperature]; hot_air_heat_capacity = [hot_air_heat_capacity]; cold_air_heat_capacity = [cold_air_heat_capacity];")

				hot_air.temperature = hot_air.temperature - energy_transfer / hot_air_heat_capacity
				cold_air.temperature = cold_air.temperature + heat / cold_air_heat_capacity

				//log_debug("POWER: [lastgen] W generated at [efficiency * 100]% efficiency and sinks sizes [cold_air_heat_capacity], [hot_air_heat_capacity]")

				add_avail(lastgen)
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
		update_icon()

	updateDialog()

/obj/machinery/power/generator/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/power/generator/attack_ghost(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	ui_interact(user)

/obj/machinery/power/generator/attack_hand(mob/user)
	if(..())
		user << browse(null, "window=teg")
		return
	ui_interact(user)

/obj/machinery/power/generator/multitool_act(mob/user, obj/item/I)
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
	update_desc()

/obj/machinery/power/generator/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	anchored = !anchored
	if(!anchored)
		disconnect()
		power_change()
	else
		connect()
	to_chat(user, "<span class='notice'>You [anchored ? "secure" : "unsecure"] the bolts holding [src] to the floor.</span>")

/obj/machinery/power/generator/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "TEG",  name, 500, 400, master_ui, state)
		ui.open()

/obj/machinery/power/generator/ui_data(mob/user)
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
		data["cold_inlet_temp"] = round(cold_circ_air2.temperature, 0.1)
		data["hot_inlet_temp"] = round(hot_circ_air2.temperature, 0.1)
		data["cold_outlet_temp"] = round(cold_circ_air1.temperature, 0.1)
		data["hot_outlet_temp"] = round(hot_circ_air1.temperature, 0.1)
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

/obj/machinery/power/generator/ui_act(action, params)
	if(..())
		return
	if(action == "check")
		if(!powernet || !cold_circ || !hot_circ)
			connect()
			return TRUE

/obj/machinery/power/generator/power_change()
	..()
	update_icon()
