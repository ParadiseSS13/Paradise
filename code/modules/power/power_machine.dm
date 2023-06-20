//////////////////////////////
// POWER MACHINERY BASE CLASS
//////////////////////////////
#warn UPDATE_ALL_OF_THIS_FOR_HV



/obj/machinery/power
	name = null
	icon = 'icons/obj/power.dmi'
	anchored = TRUE
	on_blueprints = TRUE
	power_state = NO_POWER_USE

	var/power_voltage_type = VOLTAGE_LOW

	var/powernet_connection_type = PW_CONNECTION_NODE

	var/list/linked_connectors = list()
	/// The regional powernet this power machine is hooked into
	var/datum/regional_powernet/powernet = null

/obj/machinery/power/Destroy()
	disconnect_from_network()
	return ..()


/*
	* # Power Value Getter/Setter Procs
*/
/// Adds power to the queued power cycle, will become the available power next power cycle
/obj/machinery/power/proc/produce_direct_power(amount)
	if(powernet)
		if(powernet.power_voltage_type != power_voltage_type)
			return FALSE
		powernet.queued_power_production += amount
		return TRUE
	return FALSE

/// Adds power demand to the powernet, machines should use this
/obj/machinery/power/proc/consume_direct_power(amount)
	if(!powernet)
		return
	if(powernet.power_voltage_type != power_voltage_type)
		return FALSE
	powernet.power_demand += amount
	return TRUE

/// Gets surplus power available on this machines powernet, machines should use this proc
/obj/machinery/power/proc/get_surplus()
	return powernet ? powernet.calculate_surplus() : 0

/// Gets surplus power available on this machines powernet, machines should use this proc
/obj/machinery/power/proc/get_power_balance()
	return powernet ? powernet.calculate_power_balance() : 0

/// Gets power available (NOT EXTRA) on this cables powernet, machines should use this
/obj/machinery/power/proc/get_available_power()
	return powernet ? powernet.available_power : 0

/// Adds queued power demand to be met next process cycle
/obj/machinery/power/proc/add_queued_power_demand(amount)
	powernet?.queued_power_demand += amount
	powernet.update_voltage(power_voltage_type)

/// Gets surplus power queued for next process cycle on this cables powernet
/obj/machinery/power/proc/get_queued_surplus()
	return powernet?.calculate_queued_surplus()

/// Gets available (NOT EXTRA) power queued for next process cycle on this machines powernet
/obj/machinery/power/proc/get_queued_available_power()
	return powernet?.queued_power_production


/*
	* # Powernet Connection Procs
*/
/// Attempts to connect power machine to powernetwork, returns FALSE if it fails and TRUE if it succeeds based on current machine properties
/obj/machinery/power/proc/connect_to_network(connection_method = powernet_connection_type)
	. = FALSE
	switch(connection_method)
		if(PW_CONNECTION_NODE)
			. = connect_to_node()
		if(PW_CONNECTION_CONNECTOR)
			. = connect_to_hv_connectors()

/// Connect the machine to a powernet if a node cable is present on the turf
/obj/machinery/power/proc/connect_to_node()
	var/turf/T = loc
	if(!istype(T))
		return FALSE

	var/obj/structure/cable/C = T.get_cable_node() //check if we have a node cable on the machine turf, the first found is picked

	if(isnull(C) || C.power_voltage_type != power_voltage_type || !C.powernet)
		return FALSE
	C.powernet.add_machine(src)
	return TRUE

/obj/machinery/power/proc/connect_to_hv_connectors()
	for(var/obj/machinery/power/hv_connector/connector in range(src, 1))
		if(connector.Adjacent(src) && connector.dir == get_dir(get_turf(connector), get_turf(src)))
			connector.link_power_machine(src)
			linked_connectors |= connector

// remove and disconnect the machine from its current powernet
/obj/machinery/power/proc/disconnect_from_network()
	if(length(linked_connectors))
		for(var/obj/machinery/power/hv_connector/connector as anything in linked_connectors)
			connector.disconnect_power_machine()
	if(!powernet)
		return FALSE
	powernet.remove_machine(src)
	return TRUE

// attach a wire to a power machine - leads from the turf you are standing on
//almost never called, overwritten by all power machines but terminal and generator
/obj/machinery/power/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/cable_coil/low_voltage))
		var/obj/item/stack/cable_coil/low_voltage/coil = I
		var/turf/T = user.loc
		if(T.intact || !isfloorturf(T))
			return
		if(get_dist(src, user) > 1)
			return
		coil.place_turf(T, user)
	else
		return ..()


/obj/machinery/power/proc/disconnect_terminal() // machines without a terminal will just return, no harm no fowl.
	return

////////////////////////////////////////////////
// Misc.
///////////////////////////////////////////////





