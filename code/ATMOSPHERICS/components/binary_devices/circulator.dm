//node1, air1, network1 correspond to input
//node2, air2, network2 correspond to output
/obj/machinery/atmospherics/binary/circulator
	name = "circulator/heat exchanger"
	desc = "A gas circulator pump and heat exchanger. Its input port is on the south side, and its output port is on the north side."
	icon = 'icons/obj/atmospherics/circulator.dmi'
	icon_state = "circ1-off"

	var/side = CIRC_LEFT
	
	var/global/const/CIRC_LEFT = WEST
	var/global/const/CIRC_RIGHT = EAST

	var/last_pressure_delta = 0
	
	var/obj/machinery/power/generator/generator

	layer = 2.45 // Just above wires
	
	anchored = 1
	density = 1
	
	can_unwrench = 1
	
// Creating a custom circulator pipe subtype to be delivered through cargo	
/obj/item/pipe/circulator
	name = "circulator/heat exchanger fitting"

/obj/item/pipe/circulator/New(loc)
	var/obj/machinery/atmospherics/binary/circulator/C = new /obj/machinery/atmospherics/binary/circulator(null)
	..(loc, make_from = C) 
	
/obj/machinery/atmospherics/binary/circulator/Destroy()
	if(generator && generator.cold_circ == src)
		generator.cold_circ = null
	else if(generator && generator.hot_circ == src)
		generator.hot_circ = null
	return ..()

/obj/machinery/atmospherics/binary/circulator/proc/return_transfer_air()
	var/output_starting_pressure = air1.return_pressure()
	var/input_starting_pressure = air2.return_pressure()

	if(output_starting_pressure >= input_starting_pressure - 10)
		//Need at least 10 KPa difference to overcome friction in the mechanism
		last_pressure_delta = 0
		return null

	//Calculate necessary moles to transfer using PV = nRT
	if(air2.temperature > 0)
		var/pressure_delta = (input_starting_pressure - output_starting_pressure) / 2

		var/transfer_moles = pressure_delta * air1.volume/(air2.temperature * R_IDEAL_GAS_EQUATION)

		last_pressure_delta = pressure_delta

		//log_debug("pressure_delta = [pressure_delta]; transfer_moles = [transfer_moles];")

		//Actually transfer the gas
		var/datum/gas_mixture/removed = air2.remove(transfer_moles)

		parent1.update = 1
		parent2.update = 1

		return removed

	else
		last_pressure_delta = 0

/obj/machinery/atmospherics/binary/circulator/process()
	..()
	update_icon()

/obj/machinery/atmospherics/binary/circulator/update_icon()
	if(stat & (BROKEN|NOPOWER))
		icon_state = "circ[side]-p"
	else if(last_pressure_delta > 0)
		if(last_pressure_delta > ONE_ATMOSPHERE)
			icon_state = "circ[side]-run"
		else
			icon_state = "circ[side]-slow"
	else
		icon_state = "circ[side]-off"

	return 1