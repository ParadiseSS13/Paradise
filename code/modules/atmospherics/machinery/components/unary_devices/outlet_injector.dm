GLOBAL_LIST_EMPTY(air_injectors)

/obj/machinery/atmospherics/unary/outlet_injector
	icon = 'icons/atmos/injector.dmi'
	icon_state = "map_injector"
	power_state = IDLE_POWER_USE
	layer = GAS_PIPE_VISIBLE_LAYER + GAS_SCRUBBER_OFFSET
	layer_offset = GAS_SCRUBBER_OFFSET

	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF //really helpful in building gas chambers for xenomorphs

	can_unwrench = TRUE

	name = "air injector"
	desc = "Has a valve and pump attached to it."

	var/injecting = FALSE

	var/volume_rate = 50

/obj/machinery/atmospherics/unary/outlet_injector/Initialize(mapload)
	. = ..()
	GLOB.air_injectors += src

/obj/machinery/atmospherics/unary/outlet_injector/Destroy()
	GLOB.air_injectors -= src
	return ..()

/obj/machinery/atmospherics/unary/outlet_injector/on
	on = TRUE

/obj/machinery/atmospherics/unary/outlet_injector/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Outputs the pipe's gas into the atmosphere, similar to an air vent. It can be controlled by a nearby atmospherics computer. \
			A green light on it means it is on.</span>"

/obj/machinery/atmospherics/unary/outlet_injector/update_icon_state()
	if(!has_power())
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
	if(!..())
		return
	update_icon()

/obj/machinery/atmospherics/unary/outlet_injector/process_atmos()
	injecting = FALSE

	if(!on || stat & NOPOWER)
		return 0

	if(air_contents.temperature() > 0)
		var/transfer_moles = (air_contents.return_pressure()) * volume_rate / (air_contents.temperature() * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

		var/turf/T = get_turf(src)
		T.blind_release_air(removed)

		parent.update = TRUE

	return TRUE

/obj/machinery/atmospherics/unary/outlet_injector/multitool_act(mob/living/user, obj/item/I)
	if(!ismultitool(I))
		return

	var/obj/item/multitool/M = I
	M.buffer_uid = UID()
	to_chat(user, "<span class='notice'>You save [src] into [M]'s buffer</span>")
