/obj/machinery/atmospherics/unary/portables_connector
	icon = 'icons/atmos/connector.dmi'
	icon_state = "map_connector"

	name = "connector port"
	desc = "For connecting portables devices related to atmospherics control."

	can_unwrench = TRUE
	layer = GAS_PIPE_VISIBLE_LAYER + GAS_FILTER_OFFSET
	layer_offset = GAS_FILTER_OFFSET

	var/obj/machinery/atmospherics/portable/connected_device
	/// The connected device's air version when we last asked for a share
	var/asked_version

/obj/machinery/atmospherics/unary/portables_connector/Destroy()
	if(connected_device)
		connected_device.disconnect()
	return ..()

/obj/machinery/atmospherics/unary/portables_connector/update_icon_state()
	icon_state = "connector"

/obj/machinery/atmospherics/unary/portables_connector/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node, dir)

/obj/machinery/atmospherics/unary/portables_connector/process_atmos()
	if(!connected_device)
		return 0
	// Only we can tell the device's air changed. Everything else on the pipe asks for itself
	var/datum/gas_mixture/device_air = connected_device.portableConnectorReturnAir()
	if(device_air?.version != asked_version)
		asked_version = device_air?.version
		parent.update = 1

/obj/machinery/atmospherics/unary/portables_connector/wrench_act(mob/living/user, obj/item/wrench/W)
	if(connected_device)
		to_chat(user, SPAN_DANGER("You cannot unwrench this [name], detach [connected_device] first."))
		return TRUE
	return ..()

/obj/machinery/atmospherics/unary/portables_connector/portableConnectorReturnAir()
	return connected_device.portableConnectorReturnAir()

/obj/proc/portableConnectorReturnAir()
	return
