/obj/machinery/atmospherics/binary/dp_vent_pump
	icon = 'icons/atmos/vent_pump.dmi'
	icon_state = "map_dp_vent"

	//node2 is output port
	//node1 is input port

	name = "dual-port air vent"
	desc = "Has a valve and pump attached to it. There are two ports."

	can_unwrench = TRUE

	level = 1

	connect_types = list(CONNECT_TYPE_NORMAL, CONNECT_TYPE_SUPPLY, CONNECT_TYPE_SCRUBBER) //connects to regular, supply and scrubbers pipes

	var/releasing = TRUE //FALSE = siphoning, TRUE = releasing

	var/external_pressure_bound = ONE_ATMOSPHERE
	var/input_pressure_min = 0
	var/output_pressure_max = 0

	var/pressure_checks = 1
	//1: Do not pass external_pressure_bound
	//2: Do not pass input_pressure_min
	//4: Do not pass output_pressure_max

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

/obj/machinery/atmospherics/binary/dp_vent_pump/update_overlays()
	. = ..()

	var/vent_icon = "vent"

	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	if(!has_power())
		vent_icon += "off"
	else
		vent_icon += "[on ? "[releasing ? "out" : "in"]" : "off"]"

	. += SSair.icon_manager.get_atmos_icon("device", , , vent_icon)

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
		var/icon/frame = icon('icons/atmos/vent_pump.dmi', "frame")
		underlays += frame

/obj/machinery/atmospherics/binary/dp_vent_pump/process_atmos()
	..()
	if(!on)
		return 0

	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_pressure = environment.return_pressure()

	if(releasing) //input -> external
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

