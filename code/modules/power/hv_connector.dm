
/obj/machinery/power/hv_connector
	name = "high-voltage power connector"
	desc = "a large plug which handles the transfer of high-voltage power from engines into cabling"
	icon = 'icons/obj/power.dmi'
	icon_state = "powerconnector"
	anchored = TRUE
	power_state = NO_POWER_USE
	power_voltage_type = VOLTAGE_HIGH
	/// The power terminal connected to this breakerbox
	var/obj/structure/cable/high_voltage/cable_node = null

	var/obj/machinery/power/linked_machine = null

/obj/machinery/power/hv_connector/Initialize(mapload)
	. = ..()
	connect_to_network()
	set_pixel_offsets_from_dir(2, -2, 2, -2)

/obj/machinery/power/hv_connector/connect_to_network()
	. = ..()
	if(!.)
		return
	connect_to_power_machines()
	return TRUE

/obj/machinery/power/hv_connector/proc/connect_to_power_machines()
	var/turf/adjacent_turf = get_step(src, dir)
	if(!istype(adjacent_turf))
		return
	for(var/obj/machinery/power/power_machine in adjacent_turf)
		link_power_machine(power_machine)
		break

/obj/machinery/power/hv_connector/proc/link_power_machine(obj/machinery/power/power_machine)
	if(linked_machine)
		disconnect_power_machine()
	if(powernet && istype(power_machine, /obj/machinery/power/transformer))
		powernet.subnet_connectors |= power_machine
	linked_machine = power_machine
	RegisterSignal(power_machine, COMSIG_PARENT_QDELETING)

/obj/machinery/power/hv_connector/proc/disconnect_power_machine()
	if(powernet && istype(linked_machine, /obj/machinery/power/transformer))
		powernet.subnet_connectors -= linked_machine
	UnregisterSignal(linked_machine, COMSIG_PARENT_QDELETING)
	linked_machine = null

/obj/machinery/power/hv_connector/consume_direct_power(amount)
	if(powernet.power_voltage_type == VOLTAGE_LOW)
		return FALSE
	powernet?.power_demand += amount
	powernet.update_voltage(VOLTAGE_HIGH)
	return TRUE




