/*
	* # /datum/regional_powernet
	*
	* each contiguous network of cables & nodes over a large area, unlike local powernets, these powernets
	* don't concern areas and are instead attached to a single wirenet with power machine, engine, battery, and terminal nodes
*/
/datum/regional_powernet
	/// The Powernet Unique ID Number
	var/number
	/// A list of All cables & junctions in this powernet
	var/list/cables = list()
	/// All Power Machines that are connected to this powernet
	var/list/nodes = list()

	/// the current available power in the powernet (Watts)
	var/available_power = 0
	/// the current load on the powernet, increased by each machine at processing (Watts)
	var/power_demand = 0
	/// what available power was gathered last tick, then becomes... (Watts)
	var/queued_power_production = 0
	/// load applied to powernet between power ticks. (Watts)
	var/queued_power_demand = 0
	/// excess power on the powernet (typically avail-load) (Watts)
	var/excess_power = 0

	/// the available power as it appears on the power console (gradually updated) (Watts)
	var/smoothed_available_power = 0
	/// the load as it appears on the power console (gradually updated)
	var/smoothed_demand = 0

/datum/regional_powernet/New()
	. = ..()
	SSmachines.powernets += src

/datum/regional_powernet/Destroy()
	//Go away references, you suck!
	for(var/obj/structure/cable/C as anything in cables)
		cables -= C
		C.powernet = null
	for(var/obj/machinery/power/M as anything in nodes)
		nodes -= M
		M.powernet = null

	SSmachines.powernets -= src
	return ..()

/datum/regional_powernet/proc/is_empty()
	return !length(cables) && !length(nodes)

/// remove a cable from the current powernet, if the powernet is empty after, delete it
/datum/regional_powernet/proc/remove_cable(obj/structure/cable/C)
	cables -= C
	C.powernet = null
	if(is_empty())
		qdel(src) //powernet datums are useless if they have no nodes/cables

/// add a cable to the current powernet
/datum/regional_powernet/proc/add_cable(obj/structure/cable/C)
	if(C.powernet)
		if(C.powernet != src)
			C.powernet.remove_cable(C)	//if C already has a powernet remove it
		else
			return	//already connect to this powernet, return
	C.powernet = src
	cables += C

/// remove a power machine from the current powernet, if the powernet is then empty, delete it
/datum/regional_powernet/proc/remove_machine(obj/machinery/power/M)
	nodes -= M
	M.powernet = null
	if(is_empty())	//the powernet is now empty so delete it
		qdel(src)

/// add a power machine to the current powernet
/datum/regional_powernet/proc/add_machine(obj/machinery/power/M)
	if(M.powernet)
		if(M.powernet != src)
			M.disconnect_from_network() // if M already has a powernet disconnect it from old powernet
		else
			return // already connected to this powernet, return
	M.powernet = src
	nodes[M] = M

/// Returns the clamped difference between available power on the net and the demanded power, i.g. the surplus power available
/datum/regional_powernet/proc/calculate_surplus()
	return clamp(available_power - power_demand, 0, available_power)

/// Returns the non-clamped difference between available power on the net and the demanded power, i.g. consumption vs. supply
/datum/regional_powernet/proc/calculate_power_balance()
	return (available_power - power_demand)

/datum/regional_powernet/proc/calculate_queued_surplus()
	return clamp(queued_power_production - queued_power_demand, 0, queued_power_production)
/*
	* # process_power()
	*
	* Bread and butter of the regional powernet datum, handles calculatting excess power in the net
	* and returns that excess to connected batteries. Furthermore, will clear/apply the previous usage and take
	* the new usage from the next tick after and apply it to the current power tracking vars
	*
	* called every tick by the powernet controller
*/
/datum/regional_powernet/proc/process_power()
	//Calculate excess power in the net, so the difference between how much is used vs. how much is sent into the powernet
	excess_power = calculate_surplus()

	if(excess_power > 100 && length(nodes))
		for(var/obj/machinery/power/smes/S in nodes)	// find the SMESes in the network
			S.restore()									// and restore some of the power that was used

	// update power consoles, the reason we use 80% old value and 20% new value is to give the illusion of smoothness
	smoothed_available_power = round(0.8 * smoothed_available_power + 0.2 * available_power)
	smoothed_demand = round(0.8 * smoothed_demand + 0.2 * power_demand)

	// reset the powernet
	power_demand = queued_power_demand
	queued_power_demand = 0
	available_power = queued_power_production
	queued_power_production = 0

#define MINIMUM_PW_SHOCK 1000
#define MINIMUM_SHOCK_DAMAGE 20
#define MAXIMUM_SHOCK_DAMAGE 195
#define WATT_TO_DAMAGE_RATIO 25000

/datum/regional_powernet/proc/get_electrocute_damage()
	if(available_power >= MINIMUM_PW_SHOCK)
		return clamp(MINIMUM_SHOCK_DAMAGE + round(available_power / WATT_TO_DAMAGE_RATIO), MINIMUM_SHOCK_DAMAGE, MAXIMUM_SHOCK_DAMAGE) + rand(-5, 5)
	else
		return 0

#undef MINIMUM_PW_SHOCK
#undef MINIMUM_SHOCK_DAMAGE
#undef MAXIMUM_SHOCK_DAMAGE
#undef WATT_TO_DAMAGE_RATIO
