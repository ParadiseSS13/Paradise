/**
 * ## death gases element!
 *
 * Bespoke element that spawns one type of gas when a mob is killed
 */
/datum/element/death_gases
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 3
	///What gas the target spawns when killed
	var/list/gas_types = list(SPAWN_GAS_PLASMA = 50)

/datum/element/death_gases/Attach(datum/target, list/gas_types)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	if(!gas_types)
		stack_trace("[type] added to [target] with NO GAS TYPE.")
		return ELEMENT_INCOMPATIBLE
	src.gas_types = gas_types
	RegisterSignal(target, COMSIG_MOB_DEATH, PROC_REF(on_death))

/datum/element/death_gases/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOB_DEATH)

///signal called by the stat of the target changing
/datum/element/death_gases/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER
	var/datum/gas_mixture/mix_to_spawn = new()
	for(var/gas_to_add in gas_types)
		switch(gas_to_add)
			if(SPAWN_GAS_NITROGEN)
				mix_to_spawn.set_nitrogen(gas_types[SPAWN_GAS_NITROGEN])
			if(SPAWN_GAS_OXYGEN)
				mix_to_spawn.set_oxygen(gas_types[SPAWN_GAS_OXYGEN])
			if(SPAWN_GAS_N2O)
				mix_to_spawn.sleeping_agent(gas_types[SPAWN_GAS_N2O])
			if(SPAWN_GAS_CO2)
				mix_to_spawn.set_carbon_dioxide(gas_types[SPAWN_GAS_CO2])
			if(SPAWN_GAS_PLASMA)
				mix_to_spawn.set_toxins(gas_types[SPAWN_GAS_PLASMA])
			if(SPAWN_GAS_AGENTB)
				mix_to_spawn.set_agent_b(gas_types[SPAWN_GAS_AGENTB])
			if(SPAWN_GAS_HYDROGEN)
				mix_to_spawn.set_hydrogen(gas_types[SPAWN_GAS_HYDROGEN])
			if(SPAWN_GAS_WATER)
				mix_to_spawn.set_water_vapor(gas_types[SPAWN_GAS_WATER])
	mix_to_spawn.set_temperature(T20C)
	var/turf/turf = get_turf(target)
	turf.blind_release_air(mix_to_spawn)
