/obj/machinery/atmospherics/unary/outlet_injector
	icon = 'icons/atmos/injector.dmi'
	icon_state = "map_injector"
	use_power = IDLE_POWER_USE
	layer = GAS_SCRUBBER_LAYER

	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF //really helpful in building gas chambers for xenomorphs

	can_unwrench = TRUE

	name = "air injector"
	desc = "Has a valve and pump attached to it"

	var/injecting = FALSE

	var/volume_rate = 50

/obj/machinery/atmospherics/unary/outlet_injector/on
	on = TRUE

/obj/machinery/atmospherics/unary/outlet_injector/detailed_examine()
	return "Outputs the pipe's gas into the atmosphere, similar to an air vent. It can be controlled by a nearby atmospherics computer. \
			A green light on it means it is on."

/obj/machinery/atmospherics/unary/outlet_injector/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/atmospherics/unary/outlet_injector/update_icon_state()
	if(!powered())
		icon_state = "off"
	else
		icon_state = "[on ? "on" : "off"]"

/obj/machinery/atmospherics/unary/outlet_injector/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node, dir)

/obj/machinery/atmospherics/unary/outlet_injector/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/unary/outlet_injector/process_atmos()
	..()

	injecting = FALSE

	if(!on || stat & NOPOWER)
		return 0

	if(air_contents.temperature > 0)
		var/transfer_moles = (air_contents.return_pressure())*volume_rate/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

		loc.assume_air(removed)
		air_update_turf()

		parent.update = 1

	return 1

/obj/machinery/atmospherics/unary/outlet_injector/proc/inject()
	if(on || injecting)
		return 0

	injecting = TRUE

	if(air_contents.temperature > 0)
		var/transfer_moles = (air_contents.return_pressure())*volume_rate/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

		loc.assume_air(removed)

		parent.update = 1

	flick("inject", src)

/obj/machinery/atmospherics/unary/outlet_injector/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/multitool))
		#warn AA put multitool buffer here or use multitool_act
		return 1
	if(istype(W, /obj/item/wrench))
		if(!(stat & NOPOWER) && on)
			to_chat(user, "<span class='danger'>You cannot unwrench this [src], turn if off first.</span>")
			return 1
	return ..()
