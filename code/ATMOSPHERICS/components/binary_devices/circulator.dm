//node1, air1, network1 correspond to input
//node2, air2, network2 correspond to output
/obj/machinery/atmospherics/binary/circulator
	name = "circulator/heat exchanger"
	desc = "A gas circulator pump and heat exchanger."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "circ-off"
	anchored = 0
	density = 1

	var/recent_moles_transferred = 0
	var/last_heat_capacity = 0
	var/last_temperature = 0
	var/last_pressure_delta = 0
	var/last_worldtime_transfer = 0

/obj/machinery/atmospherics/binary/circulator/New()
	..()
	desc = initial(desc) + "  Its outlet port is to the [dir2text(dir)]."

/obj/machinery/atmospherics/binary/circulator/proc/return_transfer_air()
	var/datum/gas_mixture/removed
	if(anchored && !(stat & BROKEN))
		var/input_starting_pressure = air1.return_pressure()
		var/output_starting_pressure = air2.return_pressure()
		last_pressure_delta = max(input_starting_pressure - output_starting_pressure + 10, 0)

		//only circulate air if there is a pressure difference (plus 10 kPa to represent friction in the machine)
		if(air1.temperature > 0 && last_pressure_delta > 0)

			//Calculate necessary moles to transfer using PV = nRT
			recent_moles_transferred = last_pressure_delta*air2.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			removed = air1.remove(recent_moles_transferred)
			if(removed)
				last_heat_capacity = removed.heat_capacity()
				last_temperature = removed.temperature

				//Update the gas networks.
				parent1.update = 1

				last_worldtime_transfer = world.time
		else
			recent_moles_transferred = 0

		update_icon()
		return removed

/obj/machinery/atmospherics/binary/circulator/process()
	if(!..())
		return 0
	if(last_worldtime_transfer < world.time - 50)
		recent_moles_transferred = 0
		update_icon()

/obj/machinery/atmospherics/binary/circulator/update_icon()
	if(stat & (BROKEN|NOPOWER) || !anchored)
		icon_state = "circ-p"
	else if(last_pressure_delta > 0 && recent_moles_transferred > 0)
		if(last_pressure_delta > 5*ONE_ATMOSPHERE)
			icon_state = "circ-run"
		else
			icon_state = "circ-slow"
	else
		icon_state = "circ-off"

	return 1

/obj/machinery/atmospherics/binary/circulator/attackby(var/obj/item/W as obj, var/mob/user as mob, params)
	if(istype(W, /obj/item/weapon/wrench))
		var/turf/T = get_turf(src)
		if(!istype(T, /turf/simulated))
			return ..()
		anchored = !anchored
		to_chat(user, "You [(anchored) ? "fasten" : "loosen"] \the [src] to the floor")
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
	else return ..()
