//////////////////////////////
// POWER MACHINERY BASE CLASS
//////////////////////////////
/obj/machinery/power
	name = null
	icon = 'icons/obj/power.dmi'
	anchored = TRUE
	on_blueprints = TRUE
	power_state = NO_POWER_USE

	var/datum/regional_powernet/powernet = null

/obj/machinery/power/Destroy()
	disconnect_from_network()
	return ..()
/// Adds available power to the next powernet process (Watts)
/obj/machinery/power/proc/produce_direct_power(amount)
	if(powernet)
		powernet.queued_power_production += amount
		return TRUE
	return FALSE

/// Adds power demand to the powernet (Watts)
/// machines should use this proc
/obj/machinery/power/proc/consume_direct_power(amount)
	powernet?.power_demand += amount

/// Gets surplus power available on this machine's powernet (Watts)
/obj/machinery/power/proc/get_surplus()
	return powernet ? powernet.calculate_surplus() : 0

/// Gets surplus power available on this machine's powernet (Watts)
/obj/machinery/power/proc/get_power_balance()
	return powernet ? powernet.calculate_power_balance() : 0

/// Gets power available (NOT EXTRA) on this cables powernet (Watts)
/// machines should use this proc
/obj/machinery/power/proc/get_available_power()
	return powernet ? powernet.available_power : 0

/// Adds queued power demand to be met next process cycle (Watts)
/obj/machinery/power/proc/add_queued_power_demand(amount)
	powernet?.queued_power_demand += amount

/// Gets surplus power queued for next process cycle on this cables powernet (Watts)
/obj/machinery/power/proc/get_queued_surplus()
	return powernet?.calculate_queued_surplus()

/// Gets available (NOT EXTRA) power queued for next process cycle on this machine's powernet (Watts)
/obj/machinery/power/proc/get_queued_available_power()
	return powernet?.queued_power_production

/obj/machinery/power/proc/disconnect_terminal() // machines without a terminal will just return, no harm no fowl.
	return


// connect the machine to a powernet if a node cable is present on the turf
/obj/machinery/power/proc/connect_to_network()
	var/turf/T = loc
	if(!istype(T))
		return FALSE

	var/obj/structure/cable/C = T.get_cable_node() //check if we have a node cable on the machine turf, the first found is picked

	if(!C || !C.powernet)
		return FALSE
	C.powernet.add_machine(src)
	return TRUE

// remove and disconnect the machine from its current powernet
/obj/machinery/power/proc/disconnect_from_network()
	if(!powernet)
		return FALSE
	powernet.remove_machine(src)
	return TRUE

// attach a wire to a power machine - leads from the turf you are standing on
//almost never called, overwritten by all power machines but terminal and generator
/obj/machinery/power/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = used
		var/turf/T = user.loc
		if(T.intact || !isfloorturf(T))
			return ITEM_INTERACT_COMPLETE
		if(get_dist(src, user) > 1)
			return ITEM_INTERACT_COMPLETE
		coil.place_turf(T, user)
		return ITEM_INTERACT_COMPLETE

	return ..()


////////////////////////////////////////////////
// Misc.
///////////////////////////////////////////////


// return a knot cable (O-X) if one is present in the turf
// null if there's none
/turf/proc/get_cable_node()
	if(!can_have_cabling())
		return null
	for(var/obj/structure/cable/C in src)
		if(C.d1 == NO_DIRECTION)
			return C
	return null

/area/proc/get_apc()
	for(var/thing in GLOB.apcs)
		var/obj/machinery/power/apc/APC = thing
		if(APC.apc_area == src)
			return APC
