/obj/machinery/atmospherics/unary/portables_connector
	icon = 'icons/atmos/connector.dmi'
	icon_state = "map_connector"

	name = "connector port"
	desc = "For connecting portables devices related to atmospherics control."

	can_unwrench = 1
	layer = GAS_FILTER_LAYER

	var/obj/machinery/portable_atmospherics/connected_device

	var/on = 0

/obj/machinery/atmospherics/unary/portables_connector/Destroy()
	if(connected_device)
		connected_device.disconnect()
	return ..()

/obj/machinery/atmospherics/unary/portables_connector/update_icon()
	..()
	icon_state = "connector"

/obj/machinery/atmospherics/unary/portables_connector/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node, dir)

/obj/machinery/atmospherics/unary/portables_connector/process_atmos()
	..()
	if(!connected_device)
		return 0
	parent.update = 1

/obj/machinery/atmospherics/unary/portables_connector/attackby(var/obj/item/W as obj, var/mob/user as mob, params)
	if(istype(W, /obj/item/wrench))
		if(connected_device)
			to_chat(user, "<span class='danger'>You cannot unwrench this [src], detach [connected_device] first.</span>")
			return 1
	return ..()

/obj/machinery/atmospherics/unary/portables_connector/portableConnectorReturnAir()
	return connected_device.portableConnectorReturnAir()

/obj/proc/portableConnectorReturnAir()
