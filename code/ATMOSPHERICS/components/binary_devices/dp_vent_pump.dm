/obj/machinery/atmospherics/binary/dp_vent_pump
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/vent_pump.dmi'
	icon_state = "map_dp_vent"

	//node2 is output port
	//node1 is input port

	name = "dual-port air vent"
	desc = "Has a valve and pump attached to it. There are two ports."

	can_unwrench = 1

	level = 1

	connect_types = list(1,2,3) //connects to regular, supply and scrubbers pipes

	var/on = 0
	var/pump_direction = 1 //0 = siphoning, 1 = releasing

	var/external_pressure_bound = ONE_ATMOSPHERE
	var/input_pressure_min = 0
	var/output_pressure_max = 0

	frequency = ATMOS_VENTSCRUB
	var/id_tag = null

	var/pressure_checks = 1
	//1: Do not pass external_pressure_bound
	//2: Do not pass input_pressure_min
	//4: Do not pass output_pressure_max

/obj/machinery/atmospherics/binary/dp_vent_pump/New()
	..()
	if(!id_tag)
		assign_uid()
		id_tag = num2text(uid)
	icon = null

/obj/machinery/atmospherics/binary/dp_vent_pump/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/atmospherics/binary/dp_vent_pump/init_multitool_menu()
	multitool_menu = new /datum/multitool_menu/idtag/freq/dp_vent_pump(src)

/obj/machinery/atmospherics/binary/dp_vent_pump/atmos_init()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/binary/dp_vent_pump/high_volume
	name = "large dual port air vent"

/obj/machinery/atmospherics/binary/dp_vent_pump/high_volume/on
	on = TRUE

/obj/machinery/atmospherics/binary/dp_vent_pump/high_volume/New()
	..()
	air1.volume = 1000
	air2.volume = 1000

/obj/machinery/atmospherics/binary/volume_pump/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, turn(dir, -180))
		add_underlay(T, node2, dir)

/obj/machinery/atmospherics/binary/dp_vent_pump/update_icon(var/safety = 0)
	..()

	if(!check_icon_cache())
		return

	overlays.Cut()

	var/vent_icon = "vent"

	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	if(T.intact && node1 && node2 && node1.level == 1 && node2.level == 1 && istype(node1, /obj/machinery/atmospherics/pipe) && istype(node2, /obj/machinery/atmospherics/pipe))
		vent_icon += "h"

	if(!powered())
		vent_icon += "off"
	else
		vent_icon += "[on ? "[pump_direction ? "out" : "in"]" : "off"]"

	overlays += SSair.icon_manager.get_atmos_icon("device", , , vent_icon)

/obj/machinery/atmospherics/binary/dp_vent_pump/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		if(T.intact && node1 && node2 && node1.level == 1 && node2.level == 1 && istype(node1, /obj/machinery/atmospherics/pipe) && istype(node2, /obj/machinery/atmospherics/pipe))
			return
		else
			if(node1)
				add_underlay(T, node1, turn(dir, -180), node1.icon_connect_type)
			else
				add_underlay(T, node1, turn(dir, -180))
			if(node2)
				add_underlay(T, node2, dir, node2.icon_connect_type)
			else
				add_underlay(T, node2, dir)

/obj/machinery/atmospherics/binary/dp_vent_pump/process_atmos()
	..()
	if(!on)
		return 0

	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_pressure = environment.return_pressure()

	if(pump_direction) //input -> external
		var/pressure_delta = 10000

		if(pressure_checks&1)
			pressure_delta = min(pressure_delta, (external_pressure_bound - environment_pressure))
		if(pressure_checks&2)
			pressure_delta = min(pressure_delta, (air1.return_pressure() - input_pressure_min))

		if(pressure_delta > 0)
			if(air1.temperature > 0)
				var/transfer_moles = pressure_delta*environment.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

				var/datum/gas_mixture/removed = air1.remove(transfer_moles)

				loc.assume_air(removed)

				parent1.update = 1
				air_update_turf()
	else //external -> output
		var/pressure_delta = 10000

		if(pressure_checks&1)
			pressure_delta = min(pressure_delta, (environment_pressure - external_pressure_bound))
		if(pressure_checks&4)
			pressure_delta = min(pressure_delta, (output_pressure_max - air2.return_pressure()))

		if(pressure_delta > 0)
			if(environment.temperature > 0)
				var/transfer_moles = pressure_delta*air2.volume/(environment.temperature * R_IDEAL_GAS_EQUATION)

				var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)

				air2.merge(removed)

				parent2.update = 1
				air_update_turf()
	return 1

/obj/machinery/atmospherics/binary/dp_vent_pump/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id_tag,
		"device" = "ADVP",
		"power" = on,
		"direction" = pump_direction?("release"):("siphon"),
		"checks" = pressure_checks,
		"input" = input_pressure_min,
		"output" = output_pressure_max,
		"external" = external_pressure_bound,
		"sigtype" = "status"
	)
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	return 1

/obj/machinery/atmospherics/binary/dp_vent_pump/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
		return 0
	if(signal.data["power"] != null)
		on = text2num(signal.data["power"])

	if(signal.data["power_toggle"] != null)
		on = !on

	if(signal.data["direction"] != null)
		pump_direction = text2num(signal.data["direction"])

	if(signal.data["checks"] != null)
		pressure_checks = text2num(signal.data["checks"])

	if(signal.data["purge"])
		pressure_checks &= ~1
		pump_direction = 0

	if(signal.data["stabilize"])//the fact that this was "stabalize" shows how many fucks people give about these wonders, none
		pressure_checks |= 1
		pump_direction = 1

	if(signal.data["set_input_pressure"] != null)
		input_pressure_min = between(
			0,
			text2num(signal.data["set_input_pressure"]),
			ONE_ATMOSPHERE*50
		)

	if(signal.data["set_output_pressure"] != null)
		output_pressure_max = between(
			0,
			text2num(signal.data["set_output_pressure"]),
			ONE_ATMOSPHERE*50
		)

	if(signal.data["set_external_pressure"] != null)
		external_pressure_bound = between(
			0,
			text2num(signal.data["set_external_pressure"]),
			ONE_ATMOSPHERE*50
		)

	if(signal.data["status"])
		spawn(2)
			broadcast_status()
		return //do not update_icon

	spawn(2)
		broadcast_status()
	update_icon()

/obj/machinery/atmospherics/binary/dp_vent_pump/multitool_act(mob/user, obj/item/I)
	. = TRUE
	multitool_menu.interact(user, I)
