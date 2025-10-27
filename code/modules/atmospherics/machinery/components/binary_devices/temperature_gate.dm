/obj/machinery/atmospherics/binary/temperature_gate
	icon = 'icons/atmos/temperature_gate.dmi'
	icon_state = "map"

	name = "temperature gate"

	can_unwrench = TRUE
	can_unwrench_while_on = FALSE

	// if the temperature of the input mix is lower than this, gas will flow (or higher if inverted)
	var/target_temperature = T0C

	// minimum allowed temperature - can't have anything under the coldest temperature, now can we?
	var/minimum_temperature = TCMB
	// maximum allowed temperature
	var/maximum_temperature = 4500

	var/inverted = FALSE

/obj/machinery/atmospherics/binary/temperature_gate/can_be_pulled(user, grab_state, force, show_message)
	return FALSE

/obj/machinery/atmospherics/binary/temperature_gate/CtrlClick(mob/living/user)
	if(can_use_shortcut(user))
		toggle(user)
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
	return ..()

/obj/machinery/atmospherics/binary/temperature_gate/examine(mob/user)
	. = ..()
	. += "<span class='notice'>An activable gate that compares the input temperature with the interface set temperature to check if the gas can flow from the input side to the output side or not.</span>"
	. += "<span class='notice'>It is currently set to [target_temperature] K and will allow gas to flow when the input temperature [inverted ? "is higher than" : "is lower than"] than the set temperature.</span>"

/obj/machinery/atmospherics/binary/temperature_gate/update_icon_state()
	icon_state = "[on ? "on" : "off"]"

/obj/machinery/atmospherics/binary/temperature_gate/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, turn(dir, 180))
		add_underlay(T, node2, dir)

/obj/machinery/atmospherics/binary/temperature_gate/process_atmos()
	if(!on)
		return 0

