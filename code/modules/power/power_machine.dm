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
	interact_offline = TRUE // by default, most power machines should be interactable without power :)

	/// The voltage type this machine can properly interface with on powernets
	var/power_voltage_type = VOLTAGE_LOW
	/// The default method that this power machine will use to connect to the powernet
	var/powernet_connection_type = PW_CONNECTION_NODE

	var/list/linked_connectors = list()
	/// The regional powernet this power machine is hooked into
	var/datum/regional_powernet/powernet = null

	/// How electrified this machine is, value determines the way/severity of zapping for players who interact with it
	var/electrified = MACHINE_ELECTRIFIED_NONE

/obj/machinery/power/Destroy()
	disconnect_from_network()
	return ..()


/obj/machinery/power/attack_hand(mob/user)
	. = ..()
	attack_zap_check(user)

/*
	* # Power Value Getter/Setter Procs
	*
	* Directly interacts with powernet to get/set power values. THAT IS ALL THESE PROCS SHOULD DO!
	* Should always be producing or consuming the amount given, figure out how much or little that should be before
	* calling these procs to keep it clean :P
*/
/// Adds power to the queued power cycle, will become the available power next power cycle
/obj/machinery/power/proc/produce_direct_power(amount)
	SHOULD_CALL_PARENT(TRUE)
	if(powernet)
		if(powernet.power_voltage_type != power_voltage_type)
			return FALSE
		powernet.queued_power_production += amount
		return amount
	return 0

/// Adds power demand to the powernet, machines should use this
/obj/machinery/power/proc/consume_direct_power(amount)
	if(!powernet)
		return 0
	if(powernet.power_voltage_type != power_voltage_type)
		return 0
	powernet.power_demand += amount
	return amount

/// Gets surplus power available on this machines powernet, machines should use this proc
/obj/machinery/power/proc/get_surplus()
	return powernet ? powernet.calculate_surplus() : 0

/// Gets surplus power or power debt on this machines powernet, machines should use this proc
/obj/machinery/power/proc/get_power_balance()
	return powernet ? powernet.calculate_power_balance() : 0

/// Gets power available (NOT EXTRA) on this cables powernet, machines should use this
/obj/machinery/power/proc/get_available_power()
	return powernet ? powernet.available_power : 0

/// Adds queued power demand to be met next process cycle
/obj/machinery/power/proc/add_queued_power_demand(amount)
	if(!powernet)
		return 0
	if(powernet.power_voltage_type != power_voltage_type)
		return 0
	powernet.queued_power_demand += amount
	return amount

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

	if(isnull(C) || !C.powernet)
		return FALSE
	if(short_circuit_check(C))
		return FALSE
	C.powernet.add_machine(src)
	return TRUE

/obj/machinery/power/proc/connect_to_hv_connectors()
	. = FALSE
	for(var/obj/machinery/power/hv_connector/connector in range(src, 1))
		if(connector.Adjacent(src) && connector.dir == get_dir(get_turf(connector), get_turf(src)))
			connector.link_power_machine(src)
			linked_connectors |= connector
			. = TRUE

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

/// Disconnects a connected terminal from the power machine
/obj/machinery/power/proc/disconnect_terminal() // machines without a terminal will just return, no harm no fowl.
	return

/// Called when a terminal is updated by a powernet propagation
/obj/machinery/power/proc/terminal_update()
	return

////////////////////////////////////////////////
// Misc.
///////////////////////////////////////////////

/obj/machinery/power/proc/short_circuit_check(obj/structure/cable/connecting_node)
	. = FALSE
	if(connecting_node.power_voltage_type == VOLTAGE_LOW)
		return
	if(connecting_node.power_voltage_type != power_voltage_type)
		return TRUE

/// Electricity fucking hurts! Let's make sure players understand that
/obj/machinery/power/proc/attack_zap_check(mob/living/user)
	#warn Finish Implementation
	if(!istype(user))
		return MACHINE_ELECTRIFIED_NONE
	return MACHINE_ELECTRIFIED_NONE
