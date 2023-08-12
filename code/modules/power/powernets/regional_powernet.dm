#define MINIMUM_KW_SHORT_CIRCUIT 100

/*
	* # /datum/regional_powernet
	*
	* each contiguous network of cables & nodes over a large area, unlike local powernets, these powernets
	* don't concern areas and are instead attached to a single wirenet with power machine, engine, battery, and terminal nodes
*/
/datum/regional_powernet
	/// A list of All cables & junctions in this powernet
	var/list/cables = list()
	/// All Power Machines that are connected to this powernet
	var/list/nodes = list()

	/// All the batteries on the powernet (Accumulators, SMES', etc)
	var/list/batteries = list()
	/// All devices that add load to this powernet which pull power over to another neighboring powernet
	var/list/subnet_connectors = list()

	/// All the places where a HV wire is attached to a LV cable/device (**hint** it fucking explodes!)
	var/list/short_circuit_events = list()

	/// the current available power in the powernet
	var/available_power = 0
	/// the current load on the powernet, increased by each machine at processing
	var/power_demand = 0
	/// what available power was gathered last tick, then becomes...
	var/queued_power_production = 0
	/// load applied to powernet between power ticks.
	var/queued_power_demand = 0
	/// excess power on the powernet (typically avail-load)
	var/excess_power = 0

	/// the available power as it appears on the power console (gradually updated)
	var/smoothed_available_power = 0
	/// the load as it appears on the power console (gradually updated)
	var/smoothed_demand = 0
	/// The voltage type on this powernet, determines special behaviour like transfer efficiency and merge'ing of powernets
	var/power_voltage_type = null

	/// Are we currently undergoing a rolling blackout on the net? Needed to make sure
	var/blackout = FALSE

/datum/regional_powernet/New(obj/structure/cable/root_cable, no_root = FALSE)
	. = ..()
	SSmachines.powernets += src
	if(root_cable)
		add_cable(root_cable)
		update_voltage(root_cable.power_voltage_type) // might as well set this here
	else if(!no_root)
		stack_trace("[UID()] Regional Powernet Instantiated without a root_cable")

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

/// Sets a new voltage type for the powernet, handles special behaviour when setting a new voltage
/datum/regional_powernet/proc/update_voltage(new_voltage)
	if(!new_voltage)
		stack_trace("update_voltage called with a null new_voltage type")
	if(!isnull(power_voltage_type) && new_voltage != power_voltage_type)
		return FALSE
	power_voltage_type = new_voltage
	return TRUE

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
	// # Power all of the devices hooked directly into the net and figure out how much power we have left
	excess_power = calculate_surplus()
	switch(power_voltage_type)
		if(VOLTAGE_LOW)
			process_lv_power()
		if(VOLTAGE_HIGH)
			process_hv_power()
	// # update all of our power metrics
	// update power consoles, the reason we use 80% old value and 20% new value is to give the illusion of smoothness
	smoothed_available_power = round(0.8 * smoothed_available_power + 0.2 * available_power)
	smoothed_demand = round(0.8 * smoothed_demand + 0.2 * power_demand)
	// reset the powernet
	power_demand = queued_power_demand
	queued_power_demand = 0
	available_power = queued_power_production
	queued_power_production = 0

/datum/regional_powernet/proc/process_hv_power()
	// # Divy up remaining power among our subnets (i.e. load limiters & transformers)
	feed_the_subnets()
	// # Check for shit to blow up, i.e. where there are cable voltage incompatibilities
	process_short_circuits()

/datum/regional_powernet/proc/process_lv_power()
	if(excess_power < power_demand)
		bleed_the_batteries(power_demand - available_power)
	else
		feed_the_batteries(excess_power)

/*

	* # process_transformers()
	*
	* called during process_power() after power is given out to the immediate load on the powernet (i.g. the machines hooked directly into wire nodes)
	* power is given out based on a weight system to transformers. The higher wattage setting a transformer has, the more watts that are allocated to it
	*
	* called every tick by the powernet controller through process_power()
*/
/datum/regional_powernet/proc/feed_the_subnets()
	var/total_wattage_load = 0
	// first run around to get total load being demanded by the transformers
	for(var/obj/machinery/power/transformer/transformer in subnet_connectors)
		if(!transformer.operating)
			continue
		total_wattage_load += transformer.wattage_setting
	for(var/obj/machinery/power/load_limiter/limiter in subnet_connectors)
		total_wattage_load += limiter.wattage_setting

	if(excess_power < total_wattage_load)
		// we need power, time to bleed the batteries if we have them
		bleed_the_batteries(total_wattage_load - available_power) // SUCK EM DRY
		excess_power = calculate_surplus()
		if(excess_power < total_wattage_load) // check again
			// since there's more load than supply on the net, we need to be picky about how we give out power
			for(var/obj/machinery/power/transformer/transformer in subnet_connectors)
				if(!transformer.operating)
					continue
				// will give each transformer it's own slice of the pie, enough power or too much power it don't matter
				var/power_to_give_out = round((transformer.wattage_setting / total_wattage_load) * excess_power)
				transformer.produce_direct_power(power_to_give_out)
			for(var/obj/machinery/power/load_limiter/limiter in subnet_connectors)
				// will give each transformer it's own slice of the pie, enough power or too much power it don't matter
				var/power_to_give_out = round((limiter.wattage_setting / total_wattage_load) * excess_power)
				limiter.produce_direct_power(power_to_give_out)
		else
			for(var/obj/machinery/power/transformer/transformer in subnet_connectors)
				if(!transformer.operating)
					continue
				transformer.produce_direct_power(transformer.wattage_setting)
			for(var/obj/machinery/power/load_limiter/limiter in subnet_connectors)
				limiter.produce_direct_power(limiter.wattage_setting)
	else // we have more than enough power so we can fully power each subnet connector!
		for(var/obj/machinery/power/transformer/transformer in subnet_connectors)
			if(!transformer.operating)
				continue
			transformer.produce_direct_power(transformer.wattage_setting)
			power_demand += transformer.wattage_setting
		for(var/obj/machinery/power/load_limiter/limiter in subnet_connectors)
			limiter.produce_direct_power(limiter.wattage_setting)
			power_demand += limiter.wattage_setting
		feed_the_batteries(calculate_surplus())
	power_demand += total_wattage_load

/datum/regional_powernet/proc/bleed_the_batteries(john_madden)
	var/power_per_battery = length(batteries) ? john_madden / length(batteries) : john_madden
	switch(power_voltage_type)
		if(VOLTAGE_LOW)
			for(var/obj/machinery/power/battery/smes/battery in batteries)
				battery.produce_direct_power()
		if(VOLTAGE_HIGH)
			var/left_over_demand = 0
			var/list/depleted_batteries = list()
			// round 1, try and grab roughly equal amounts of power from each battery
			for(var/obj/machinery/power/battery/accumulator/battery in batteries)
				var/power_bled = battery.consume_charge(power_per_battery + left_over_demand)
				battery.produce_direct_power(power_bled)
				left_over_demand = (power_per_battery + left_over_demand) - power_bled
				if(left_over_demand)
					depleted_batteries |= battery
			if(left_over_demand)
				// round 2, now we just start grabbing as much power as possible to fill our leftover power demand from each battery we hit
				for(var/obj/machinery/power/battery/accumulator/battery in (batteries - depleted_batteries))
					var/power_bled = battery.consume_charge(left_over_demand)
					battery.produce_direct_power(power_bled)
					left_over_demand -= power_bled

					if(!left_over_demand)
						break

/datum/regional_powernet/proc/feed_the_batteries(john_madden)
	switch(power_voltage_type)
		if(VOLTAGE_LOW)
			return 0
		if(VOLTAGE_HIGH)
			var/amount_to_restore = round(john_madden / max(1, length(batteries)))
			var/left_over_charge = 0
			for(var/obj/machinery/power/battery/accumulator/battery in batteries)
				// our left over charge is equal to the different between what charge we were able to add and what we actually added
				var/previous_left_over = left_over_charge
				left_over_charge = (amount_to_restore + left_over_charge) - battery.add_charge(amount_to_restore + left_over_charge)
				battery.consume_direct_power(amount_to_restore - (previous_left_over - left_over_charge))
			return left_over_charge

/datum/regional_powernet/proc/short_circuit(datum/regional_powernet/trgt_powernet, obj/src_node)
	message_admins("Short Circuit Detected: HV: [UID()] LV: [trgt_powernet.UID()] at [ADMIN_COORDJMP(src_node)]")
	if(available_power < MINIMUM_KW_SHORT_CIRCUIT)
		return FALSE
	if(iscable(src_node))
		for(var/datum/short_circuit_event/wire/event in short_circuit_events)
			if(src_node in event.affected_cables)
				return FALSE // already shortcircuiting
		short_circuit_events += new /datum/short_circuit_event/wire(src, trgt_powernet, src_node, 5)
		return TRUE
	if(ispowermachine(src_node))
		for(var/datum/short_circuit_event/machine/event in short_circuit_events)
			if(src_node == event.affected_machine)
				return FALSE // already shortcircuiting
		short_circuit_events += new /datum/short_circuit_event/machine(src, trgt_powernet, src_node)
		return TRUE
	return FALSE

/datum/regional_powernet/proc/process_short_circuits()
	for(var/datum/short_circuit_event/event in short_circuit_events)
		event.process_short_circuit()

/*
	* # low_power_flicker
	* Indicate to a room/area on this powernet that there is low power by flickering lights and machinery
	* intensity - 1 to 5 value which controls how much flickering is done
*/
/datum/regional_powernet/proc/low_power_flicker(intensity = 1, silent = TRUE)
	var/list/apc_targets = list()
	for(var/obj/machinery/power/apc/apc in nodes)
		apc_targets += apc
	var/victim_count = length(apc_targets) / (6 - intensity)
	for(var/i in 1 to victim_count)
		var/obj/machinery/power/apc/the_victim = pick_n_take(apc_targets)
		if(intensity >= 3 && !silent)
			// now we start playing warning sounds for players, at this point the transformer needs to be dealt with or a lot of players will get angry :)
			#warn play sound for victims
		var/list/victim_machines = the_victim.machine_powernet.registered_machines
		var/victim_machine_count = length(the_victim.machine_powernet.registered_machines) / (6 - intensity)
		for(var/j in 1 to victim_machine_count)
			var/obj/machinery/victim_machine = pick_n_take(victim_machines)
			victim_machine.flicker() // boo bitch!

/datum/regional_powernet/proc/powernet_overload()
	return

/// A full powernet blackout of the powernet, will cinematically shut down all APCs in an area by turning off their breaker over 10 seconds
/datum/regional_powernet/proc/rolling_blackout()
	var/list/apc_targets = list()
	var/apc_count = length(apc_targets)
	var/apc_rounds = CEILING(apc_count / 10, 1)
	if(!apc_count)
		CRASH("proc rolling_blackout called on a powernet without apcs")
	for(var/obj/machinery/power/apc/apc in nodes)
		apc_targets += apc
	var/blackout_wait = (1 SECONDS)
	for(var/i in 1 to 10)
		var/list/blackout_apcs = pick_multiple_unique(apc_targets, apc_rounds)
		apc_rounds -= blackout_apcs
		addtimer(CALLBACK(src, PROC_REF(do_apc_blackout), blackout_apcs), blackout_wait)
		blackout_wait += (1 SECONDS) // this is what we mean by rolling blackout

/datum/regional_powernet/proc/do_apc_blackout(list/blackout_apcs = list())
	if(!length(blackout_apcs))
		return
	for(var/obj/machinery/power/apc/apc in blackout_apcs)
		if(apc.operating)
			apc.toggle_breaker()
			for(var/mob/player in apc.apc_area)
				if(!player.client)
					continue
				#warn play blackout sound
				player.playsound_local(get_turf(player), 'sound/ambience/antag/malf.ogg', 50, FALSE)

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
