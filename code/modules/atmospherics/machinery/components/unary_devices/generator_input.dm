/obj/machinery/atmospherics/unary/generator_input
	icon = 'icons/obj/atmospherics/heat_exchanger.dmi'
	icon_state = "intact"
	density = TRUE

	name = "generator input"
	desc = "Placeholder."

	var/update_cycle

/obj/machinery/atmospherics/unary/generator_input/update_icon_state()
	if(node)
		icon_state = "intact"
	else
		icon_state = "exposed"

/obj/machinery/atmospherics/unary/generator_input/proc/return_exchange_air()
	return air_contents
