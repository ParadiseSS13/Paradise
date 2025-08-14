 /*
What are the archived variables for?
	Calculations are done using the archived variables with the results merged into the regular variables.
	This prevents race conditions that arise based on the order of tile processing.
*/
#define SPECIFIC_HEAT_TOXIN		200
#define SPECIFIC_HEAT_AIR		20
#define SPECIFIC_HEAT_CDO		30
#define SPECIFIC_HEAT_N2O		40
#define SPECIFIC_HEAT_AGENT_B	300

#define HEAT_CAPACITY_CALCULATION(oxygen, carbon_dioxide, nitrogen, toxins, sleeping_agent, agent_b, innate_heat_capacity) \
	(carbon_dioxide * SPECIFIC_HEAT_CDO + (oxygen + nitrogen) * SPECIFIC_HEAT_AIR + toxins * SPECIFIC_HEAT_TOXIN + sleeping_agent * SPECIFIC_HEAT_N2O + agent_b * SPECIFIC_HEAT_AGENT_B + innate_heat_capacity)

#define MINIMUM_HEAT_CAPACITY	0.0003
#define MINIMUM_MOLE_COUNT		0.01
#define QUANTIZE(variable)		(round(variable, 0.0001))

/datum/gas_mixture
	/// The volume this gas mixture fills.
	var/volume = CELL_VOLUME
	/// Heat capacity intrinsic to the container of this gas mixture.
	var/innate_heat_capacity = 0
	/// How much fuel this gas mixture burnt last reaction.
	var/fuel_burnt = 0

	// Private fields. Use the matching procs to get and set them.
	// e.g. GM.oxygen(), GM.set_oxygen()
	var/private_oxygen = 0
	var/private_carbon_dioxide = 0
	var/private_nitrogen = 0
	var/private_toxins = 0
	var/private_sleeping_agent = 0
	var/private_agent_b = 0
	var/private_temperature = 0 //in Kelvin
	var/private_hotspot_temperature = 0
	var/private_hotspot_volume = 0
	var/private_fuel_burnt = 0

	// Archived versions of the private fields.
	// Only gas_mixture should use these.
	var/private_oxygen_archived = 0
	var/private_carbon_dioxide_archived = 0
	var/private_nitrogen_archived = 0
	var/private_toxins_archived = 0
	var/private_sleeping_agent_archived = 0
	var/private_agent_b_archived = 0
	var/private_temperature_archived = 0

	/// Is this mixture currently synchronized with MILLA? Always true for non-bound mixtures.
	var/synchronized = TRUE

/// Marks this gas mixture as changed from MILLA. Does nothing on non-bound mixtures.
/datum/gas_mixture/proc/set_dirty()
	return

/datum/gas_mixture/proc/oxygen()
	return private_oxygen

/datum/gas_mixture/proc/set_oxygen(value)
	if(isnan(value) || !isnum(value))
		CRASH("Bad value: [value]")
	var/clamped = clamp(value, 0, 1e10)
	if(value != clamped)
		stack_trace("Out-of-bounds value [value] clamped to [clamped].")
	private_oxygen = clamped

/datum/gas_mixture/proc/carbon_dioxide()
	return private_carbon_dioxide

/datum/gas_mixture/proc/set_carbon_dioxide(value)
	if(isnan(value) || !isnum(value))
		CRASH("Bad value: [value]")
	var/clamped = clamp(value, 0, 1e10)
	if(value != clamped)
		stack_trace("Out-of-bounds value [value] clamped to [clamped].")
	private_carbon_dioxide = clamped

/datum/gas_mixture/proc/nitrogen()
	return private_nitrogen

/datum/gas_mixture/proc/set_nitrogen(value)
	if(isnan(value) || !isnum(value))
		CRASH("Bad value: [value]")
	var/clamped = clamp(value, 0, 1e10)
	if(value != clamped)
		stack_trace("Out-of-bounds value [value] clamped to [clamped].")
	private_nitrogen = clamped

/datum/gas_mixture/proc/toxins()
	return private_toxins

/datum/gas_mixture/proc/set_toxins(value)
	if(isnan(value) || !isnum(value))
		CRASH("Bad value: [value]")
	var/clamped = clamp(value, 0, 1e10)
	if(value != clamped)
		stack_trace("Out-of-bounds value [value] clamped to [clamped].")
	private_toxins = clamped

/datum/gas_mixture/proc/sleeping_agent()
	return private_sleeping_agent

/datum/gas_mixture/proc/set_sleeping_agent(value)
	if(isnan(value) || !isnum(value))
		CRASH("Bad value: [value]")
	var/clamped = clamp(value, 0, 1e10)
	if(value != clamped)
		stack_trace("Out-of-bounds value [value] clamped to [clamped].")
	private_sleeping_agent = clamped

/datum/gas_mixture/proc/agent_b()
	return private_agent_b

/datum/gas_mixture/proc/set_agent_b(value)
	if(isnan(value) || !isnum(value))
		CRASH("Bad value: [value]")
	var/clamped = clamp(value, 0, 1e10)
	if(value != clamped)
		stack_trace("Out-of-bounds value [value] clamped to [clamped].")
	private_agent_b = clamped

/datum/gas_mixture/proc/temperature()
	return private_temperature

/datum/gas_mixture/proc/set_temperature(value)
	if(isnan(value) || !isnum(value))
		CRASH("Bad value: [value]")
	var/clamped = clamp(value, 0, 1e10)
	if(value != clamped)
		stack_trace("Out-of-bounds value [value] clamped to [clamped].")
	private_temperature = clamped

/datum/gas_mixture/proc/hotspot_temperature()
	return private_hotspot_temperature

/datum/gas_mixture/proc/hotspot_volume()
	return private_hotspot_volume

/datum/gas_mixture/proc/fuel_burnt()
	return private_fuel_burnt

	///joules per kelvin
/datum/gas_mixture/proc/heat_capacity()
	return HEAT_CAPACITY_CALCULATION(private_oxygen, private_carbon_dioxide, private_nitrogen, private_toxins, private_sleeping_agent, private_agent_b, innate_heat_capacity)

/datum/gas_mixture/proc/heat_capacity_archived()
	return HEAT_CAPACITY_CALCULATION(private_oxygen_archived, private_carbon_dioxide_archived, private_nitrogen_archived, private_toxins_archived, private_sleeping_agent_archived, private_agent_b_archived, innate_heat_capacity)

	/// Calculate moles
/datum/gas_mixture/proc/total_moles()
	return private_oxygen + private_carbon_dioxide + private_nitrogen + private_toxins + private_sleeping_agent + private_agent_b

/datum/gas_mixture/proc/total_trace_moles()
	return private_agent_b

	/// Calculate pressure in kilopascals
/datum/gas_mixture/proc/return_pressure()
	if(volume > 0)
		return total_moles() * R_IDEAL_GAS_EQUATION * private_temperature / volume
	return 0

	/// Calculate volume in liters
/datum/gas_mixture/proc/return_volume()
	return max(0, volume)

	/// Calculate thermal energy in joules
/datum/gas_mixture/proc/thermal_energy()
	return private_temperature * heat_capacity()

	///Update archived versions of variables. Returns: TRUE in all cases
/datum/gas_mixture/proc/archive()
	private_oxygen_archived = private_oxygen
	private_carbon_dioxide_archived = private_carbon_dioxide
	private_nitrogen_archived =  private_nitrogen
	private_toxins_archived = private_toxins
	private_sleeping_agent_archived = private_sleeping_agent
	private_agent_b_archived = private_agent_b

	private_temperature_archived = private_temperature

	return TRUE

	///Merges all air from giver into self. Deletes giver. Returns: TRUE if we are mutable, FALSE otherwise
/datum/gas_mixture/proc/merge(datum/gas_mixture/giver)
	if(!giver)
		return FALSE


	if(abs(private_temperature - giver.private_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity()
		var/giver_heat_capacity = giver.heat_capacity()
		var/combined_heat_capacity = giver_heat_capacity + self_heat_capacity
		if(combined_heat_capacity != 0)
			private_temperature = (giver.private_temperature * giver_heat_capacity + private_temperature * self_heat_capacity) / combined_heat_capacity

	private_oxygen += giver.private_oxygen
	private_carbon_dioxide += giver.private_carbon_dioxide
	private_nitrogen += giver.private_nitrogen
	private_toxins += giver.private_toxins
	private_sleeping_agent += giver.private_sleeping_agent
	private_agent_b += giver.private_agent_b

	set_dirty()
	return TRUE

	/// Only removes the gas if we have more than the amount
/datum/gas_mixture/proc/boolean_remove(amount)
	if(amount > total_moles())
		return FALSE
	return remove(amount)

	///Proportionally removes amount of gas from the gas_mixture.
	///Returns: gas_mixture with the gases removed
/datum/gas_mixture/proc/remove(amount)

	var/sum = total_moles()
	amount = min(amount, sum) //Can not take more air than tile has!
	if(amount <= 0)
		return null

	var/datum/gas_mixture/removed = new


	removed.private_oxygen = QUANTIZE((private_oxygen / sum) * amount)
	removed.private_nitrogen = QUANTIZE((private_nitrogen/  sum) * amount)
	removed.private_carbon_dioxide = QUANTIZE((private_carbon_dioxide / sum) * amount)
	removed.private_toxins = QUANTIZE((private_toxins / sum) * amount)
	removed.private_sleeping_agent = QUANTIZE((private_sleeping_agent / sum) * amount)
	removed.private_agent_b = QUANTIZE((private_agent_b / sum) * amount)

	private_oxygen = max(private_oxygen - removed.private_oxygen, 0)
	private_nitrogen = max(private_nitrogen - removed.private_nitrogen, 0)
	private_carbon_dioxide = max(private_carbon_dioxide - removed.private_carbon_dioxide, 0)
	private_toxins = max(private_toxins - removed.private_toxins, 0)
	private_sleeping_agent = max(private_sleeping_agent - removed.private_sleeping_agent, 0)
	private_agent_b = max(private_agent_b - removed.private_agent_b, 0)

	removed.private_temperature = private_temperature

	set_dirty()
	return removed

	///Proportionally removes amount of gas from the gas_mixture.
	///Returns: gas_mixture with the gases removed
/datum/gas_mixture/proc/remove_ratio(ratio)

	if(ratio <= 0)
		return null

	ratio = min(ratio, 1)

	var/datum/gas_mixture/removed = new

	removed.private_oxygen = QUANTIZE(private_oxygen * ratio)
	removed.private_nitrogen = QUANTIZE(private_nitrogen * ratio)
	removed.private_carbon_dioxide = QUANTIZE(private_carbon_dioxide * ratio)
	removed.private_toxins = QUANTIZE(private_toxins * ratio)
	removed.private_sleeping_agent = QUANTIZE(private_sleeping_agent * ratio)
	removed.private_agent_b = QUANTIZE(private_agent_b * ratio)

	private_oxygen = max(private_oxygen - removed.private_oxygen, 0)
	private_nitrogen = max(private_nitrogen - removed.private_nitrogen, 0)
	private_carbon_dioxide = max(private_carbon_dioxide - removed.private_carbon_dioxide, 0)
	private_toxins = max(private_toxins - removed.private_toxins, 0)
	private_sleeping_agent = max(private_sleeping_agent - removed.private_sleeping_agent, 0)
	private_agent_b = max(private_agent_b - removed.private_agent_b, 0)

	removed.private_temperature = private_temperature
	set_dirty()

	return removed

	//Copies variables from sample
/datum/gas_mixture/proc/copy_from(datum/gas_mixture/sample)
	private_oxygen = sample.private_oxygen
	private_carbon_dioxide = sample.private_carbon_dioxide
	private_nitrogen = sample.private_nitrogen
	private_toxins = sample.private_toxins
	private_sleeping_agent = sample.private_sleeping_agent
	private_agent_b = sample.private_agent_b

	private_temperature = sample.private_temperature
	set_dirty()

	return TRUE

	///Copies all gas info from the turf into the gas list along with temperature
	///Returns: TRUE if we are mutable, FALSE otherwise
/datum/gas_mixture/proc/copy_from_turf(turf/model)
	private_oxygen = model.oxygen
	private_carbon_dioxide = model.carbon_dioxide
	private_nitrogen = model.nitrogen
	private_toxins = model.toxins
	private_sleeping_agent = model.sleeping_agent
	private_agent_b = model.agent_b

	//acounts for changes in temperature
	var/turf/model_parent = model.parent_type
	if(model.temperature != initial(model.temperature) || model.temperature != initial(model_parent.temperature))
		private_temperature = model.temperature
	set_dirty()

	return TRUE

	///Performs air sharing calculations between two gas_mixtures assuming only 1 boundary length
	///Returns: amount of gas exchanged (+ if sharer received)
/datum/gas_mixture/proc/share(datum/gas_mixture/sharer, atmos_adjacent_turfs = 4)
	if(!sharer)
		return 0
	/// Don't make calculations if there is no difference.
	if(private_oxygen_archived == sharer.private_oxygen_archived && private_carbon_dioxide_archived == sharer.private_carbon_dioxide_archived && private_nitrogen_archived == sharer.private_nitrogen_archived &&\
	private_toxins_archived == sharer.private_toxins_archived && private_sleeping_agent_archived == sharer.private_sleeping_agent_archived && private_agent_b_archived == sharer.private_agent_b_archived && private_temperature_archived == sharer.private_temperature_archived)
		return 0
	var/delta_oxygen = QUANTIZE(private_oxygen_archived - sharer.private_oxygen_archived) / (atmos_adjacent_turfs + 1)
	var/delta_carbon_dioxide = QUANTIZE(private_carbon_dioxide_archived - sharer.private_carbon_dioxide_archived) / (atmos_adjacent_turfs + 1)
	var/delta_nitrogen = QUANTIZE(private_nitrogen_archived - sharer.private_nitrogen_archived) / (atmos_adjacent_turfs + 1)
	var/delta_toxins = QUANTIZE(private_toxins_archived - sharer.private_toxins_archived) / (atmos_adjacent_turfs + 1)
	var/delta_sleeping_agent = QUANTIZE(private_sleeping_agent_archived - sharer.private_sleeping_agent_archived) / (atmos_adjacent_turfs + 1)
	var/delta_agent_b = QUANTIZE(private_agent_b_archived - sharer.private_agent_b_archived) / (atmos_adjacent_turfs + 1)

	var/delta_temperature = (private_temperature_archived - sharer.private_temperature_archived)

	var/old_self_heat_capacity = 0
	var/old_sharer_heat_capacity = 0

	var/heat_capacity_self_to_sharer = 0
	var/heat_capacity_sharer_to_self = 0

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)

		var/delta_air = delta_oxygen + delta_nitrogen
		if(delta_air)
			var/air_heat_capacity = SPECIFIC_HEAT_AIR * delta_air
			if(delta_air > 0)
				heat_capacity_self_to_sharer += air_heat_capacity
			else
				heat_capacity_sharer_to_self -= air_heat_capacity

		if(delta_carbon_dioxide)
			var/carbon_dioxide_heat_capacity = SPECIFIC_HEAT_CDO * delta_carbon_dioxide
			if(delta_carbon_dioxide > 0)
				heat_capacity_self_to_sharer += carbon_dioxide_heat_capacity
			else
				heat_capacity_sharer_to_self -= carbon_dioxide_heat_capacity

		if(delta_toxins)
			var/toxins_heat_capacity = SPECIFIC_HEAT_TOXIN * delta_toxins
			if(delta_toxins > 0)
				heat_capacity_self_to_sharer += toxins_heat_capacity
			else
				heat_capacity_sharer_to_self -= toxins_heat_capacity

		if(delta_sleeping_agent)
			var/sleeping_agent_heat_capacity = SPECIFIC_HEAT_N2O * delta_sleeping_agent
			if(delta_sleeping_agent > 0)
				heat_capacity_self_to_sharer += sleeping_agent_heat_capacity
			else
				heat_capacity_sharer_to_self -= sleeping_agent_heat_capacity

		if(delta_agent_b)
			var/agent_b_heat_capacity = SPECIFIC_HEAT_AGENT_B * delta_agent_b
			if(delta_agent_b > 0)
				heat_capacity_self_to_sharer += agent_b_heat_capacity
			else
				heat_capacity_sharer_to_self -= agent_b_heat_capacity

		old_self_heat_capacity = heat_capacity()
		old_sharer_heat_capacity = sharer.heat_capacity()

	private_oxygen -= delta_oxygen
	sharer.private_oxygen += delta_oxygen

	private_carbon_dioxide -= delta_carbon_dioxide
	sharer.private_carbon_dioxide += delta_carbon_dioxide

	private_nitrogen -= delta_nitrogen
	sharer.private_nitrogen += delta_nitrogen

	private_toxins -= delta_toxins
	sharer.private_toxins += delta_toxins

	private_sleeping_agent -= delta_sleeping_agent
	sharer.private_sleeping_agent += delta_sleeping_agent

	private_agent_b -= delta_agent_b
	sharer.private_agent_b += delta_agent_b

	var/moved_moles = (delta_oxygen + delta_carbon_dioxide + delta_nitrogen + delta_toxins + delta_sleeping_agent + delta_agent_b)

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/new_self_heat_capacity = old_self_heat_capacity + heat_capacity_sharer_to_self - heat_capacity_self_to_sharer
		var/new_sharer_heat_capacity = old_sharer_heat_capacity + heat_capacity_self_to_sharer - heat_capacity_sharer_to_self

		if(new_self_heat_capacity > MINIMUM_HEAT_CAPACITY)
			private_temperature = (old_self_heat_capacity * private_temperature - heat_capacity_self_to_sharer * private_temperature_archived + heat_capacity_sharer_to_self * sharer.private_temperature_archived) / new_self_heat_capacity

		if(new_sharer_heat_capacity > MINIMUM_HEAT_CAPACITY)
			sharer.private_temperature = (old_sharer_heat_capacity * sharer.private_temperature - heat_capacity_sharer_to_self * sharer.private_temperature_archived + heat_capacity_self_to_sharer * private_temperature_archived) / new_sharer_heat_capacity

			if(abs(old_sharer_heat_capacity) > MINIMUM_HEAT_CAPACITY)
				if(abs(new_sharer_heat_capacity / old_sharer_heat_capacity - 1) < 0.10) // <10% change in sharer heat capacity
					temperature_share(sharer, OPEN_HEAT_TRANSFER_COEFFICIENT)

	set_dirty()
	if((delta_temperature > MINIMUM_TEMPERATURE_TO_MOVE) || abs(moved_moles) > MINIMUM_MOLES_DELTA_TO_MOVE)
		var/delta_pressure = private_temperature_archived * (total_moles() + moved_moles) - sharer.private_temperature_archived * (sharer.total_moles() - moved_moles)
		return delta_pressure * R_IDEAL_GAS_EQUATION / volume

	//Similar to share(...), except the model is not modified
	//Return: amount of gas exchanged
/datum/gas_mixture/proc/mimic(turf/model, atmos_adjacent_turfs = 4) //I want this proc to die a painful death
	var/delta_oxygen = QUANTIZE(private_oxygen_archived - model.oxygen) / (atmos_adjacent_turfs + 1)
	var/delta_carbon_dioxide = QUANTIZE(private_carbon_dioxide_archived - model.carbon_dioxide) / (atmos_adjacent_turfs + 1)
	var/delta_nitrogen = QUANTIZE(private_nitrogen_archived - model.nitrogen) / (atmos_adjacent_turfs + 1)
	var/delta_toxins = QUANTIZE(private_toxins_archived - model.toxins) / (atmos_adjacent_turfs + 1)
	var/delta_sleeping_agent = QUANTIZE(private_sleeping_agent_archived - model.sleeping_agent) / (atmos_adjacent_turfs + 1)
	var/delta_agent_b = QUANTIZE(private_agent_b_archived - model.agent_b) / (atmos_adjacent_turfs + 1)

	var/delta_temperature = (private_temperature_archived - model.temperature)

	var/heat_transferred = 0
	var/old_self_heat_capacity = 0
	var/heat_capacity_transferred = 0

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)

		var/delta_air = delta_oxygen + delta_nitrogen
		if(delta_air)
			var/air_heat_capacity = SPECIFIC_HEAT_AIR * delta_air
			heat_transferred -= air_heat_capacity * model.temperature
			heat_capacity_transferred -= air_heat_capacity

		if(delta_carbon_dioxide)
			var/carbon_dioxide_heat_capacity = SPECIFIC_HEAT_CDO * delta_carbon_dioxide
			heat_transferred -= carbon_dioxide_heat_capacity * model.temperature
			heat_capacity_transferred -= carbon_dioxide_heat_capacity

		if(delta_toxins)
			var/toxins_heat_capacity = SPECIFIC_HEAT_TOXIN * delta_toxins
			heat_transferred -= toxins_heat_capacity * model.temperature
			heat_capacity_transferred -= toxins_heat_capacity

		if(delta_sleeping_agent)
			var/sleeping_agent_heat_capacity = SPECIFIC_HEAT_N2O * delta_sleeping_agent
			heat_transferred -= sleeping_agent_heat_capacity * model.temperature
			heat_capacity_transferred -= sleeping_agent_heat_capacity

		if(delta_agent_b)
			var/agent_b_heat_capacity = SPECIFIC_HEAT_AGENT_B * delta_agent_b
			heat_transferred -= agent_b_heat_capacity * model.temperature
			heat_capacity_transferred -= agent_b_heat_capacity

		old_self_heat_capacity = heat_capacity()

	private_oxygen -= delta_oxygen
	private_carbon_dioxide -= delta_carbon_dioxide
	private_nitrogen -= delta_nitrogen
	private_toxins -= delta_toxins
	private_sleeping_agent -= delta_sleeping_agent
	private_agent_b -= delta_agent_b

	var/moved_moles = (delta_oxygen + delta_carbon_dioxide + delta_nitrogen + delta_toxins + delta_sleeping_agent + delta_agent_b)

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/new_self_heat_capacity = old_self_heat_capacity - heat_capacity_transferred
		if(new_self_heat_capacity > MINIMUM_HEAT_CAPACITY)
			private_temperature = (old_self_heat_capacity * private_temperature - heat_capacity_transferred * private_temperature_archived) / new_self_heat_capacity

		temperature_mimic(model, model.thermal_conductivity)

	set_dirty()
	if((delta_temperature > MINIMUM_TEMPERATURE_TO_MOVE) || abs(moved_moles) > MINIMUM_MOLES_DELTA_TO_MOVE)
		var/delta_pressure = private_temperature_archived * (total_moles() + moved_moles) - model.temperature * (model.oxygen + model.carbon_dioxide + model.nitrogen + model.toxins + model.sleeping_agent + model.agent_b)
		return delta_pressure * R_IDEAL_GAS_EQUATION / volume
	else
		return 0

	//Returns: FALSE if self-check failed or TRUE if check passes
/datum/gas_mixture/proc/check_turf(turf/model, atmos_adjacent_turfs = 4) //I want this proc to die a painful death
	var/delta_oxygen = (private_oxygen_archived - model.oxygen) / (atmos_adjacent_turfs + 1)
	var/delta_carbon_dioxide = (private_carbon_dioxide_archived - model.carbon_dioxide) / (atmos_adjacent_turfs + 1)
	var/delta_nitrogen = (private_nitrogen_archived - model.nitrogen) / (atmos_adjacent_turfs + 1)
	var/delta_toxins = (private_toxins_archived - model.toxins) / (atmos_adjacent_turfs + 1)
	var/delta_sleeping_agent = (private_sleeping_agent_archived - model.sleeping_agent) / (atmos_adjacent_turfs + 1)
	var/delta_agent_b = (private_agent_b_archived - model.agent_b) / (atmos_adjacent_turfs + 1)

	var/delta_temperature = (private_temperature_archived - model.temperature)

	if(((abs(delta_oxygen) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_oxygen) >= private_oxygen_archived * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_carbon_dioxide) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_carbon_dioxide) >= private_carbon_dioxide_archived * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_nitrogen) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_nitrogen) >= private_nitrogen_archived * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_toxins) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_toxins) >= private_toxins_archived * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_sleeping_agent) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_sleeping_agent) >= private_sleeping_agent_archived * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_agent_b) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_agent_b) >= private_agent_b_archived * MINIMUM_AIR_RATIO_TO_SUSPEND)))
		return FALSE
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND)
		return FALSE

	return TRUE

/datum/gas_mixture/proc/temperature_mimic(turf/model, conduction_coefficient) //I want this proc to die a painful death
	set_dirty()
	var/delta_temperature = (private_temperature - model.temperature)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity()

		if((model.heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient * delta_temperature * \
				(self_heat_capacity * model.heat_capacity / (self_heat_capacity + model.heat_capacity))

			private_temperature -= heat / self_heat_capacity

	///Performs temperature sharing calculations (via conduction) between two gas_mixtures assuming only 1 boundary length
	///Returns: new temperature of the sharer
/datum/gas_mixture/proc/temperature_share(datum/gas_mixture/sharer, conduction_coefficient)

	var/delta_temperature = (private_temperature_archived - sharer.private_temperature_archived)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		set_dirty()
		var/self_heat_capacity = heat_capacity_archived()
		var/sharer_heat_capacity = sharer.heat_capacity_archived()

		if((sharer_heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*delta_temperature * \
				(self_heat_capacity * sharer_heat_capacity / (self_heat_capacity + sharer_heat_capacity))

			private_temperature -= heat / self_heat_capacity
			sharer.private_temperature += heat / sharer_heat_capacity

/datum/gas_mixture/proc/temperature_turf_share(turf/simulated/sharer, conduction_coefficient) //I want this proc to die a painful death
	var/delta_temperature = (private_temperature_archived - sharer.temperature)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		set_dirty()
		var/self_heat_capacity = heat_capacity()

		if((sharer.heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient * delta_temperature * \
				(self_heat_capacity * sharer.heat_capacity / (self_heat_capacity + sharer.heat_capacity))

			private_temperature -= heat / self_heat_capacity
			sharer.temperature += heat / sharer.heat_capacity

	//Compares sample to self to see if within acceptable ranges that group processing may be enabled
/datum/gas_mixture/proc/compare(datum/gas_mixture/sample)
	if((abs(private_oxygen - sample.private_oxygen) > MINIMUM_AIR_TO_SUSPEND) && \
		((private_oxygen < (1 - MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.private_oxygen) || (private_oxygen > (1 + MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.private_oxygen)))
		return FALSE
	if((abs(private_nitrogen - sample.private_nitrogen) > MINIMUM_AIR_TO_SUSPEND) && \
		((private_nitrogen < (1 - MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.private_nitrogen) || (private_nitrogen > (1 + MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.private_nitrogen)))
		return FALSE
	if((abs(private_carbon_dioxide - sample.private_carbon_dioxide) > MINIMUM_AIR_TO_SUSPEND) && \
		((private_carbon_dioxide < (1 - MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.private_carbon_dioxide) || (private_carbon_dioxide > (1 + MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.private_carbon_dioxide)))
		return FALSE
	if((abs(private_toxins - sample.private_toxins) > MINIMUM_AIR_TO_SUSPEND) && \
		((private_toxins < (1 - MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.private_toxins) || (private_toxins > (1 + MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.private_toxins)))
		return FALSE
	if((abs(private_sleeping_agent - sample.private_sleeping_agent) > MINIMUM_AIR_TO_SUSPEND) && \
		((private_sleeping_agent < (1 - MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.private_sleeping_agent) || (private_sleeping_agent > (1 + MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.private_sleeping_agent)))
		return FALSE
	if((abs(private_agent_b - sample.private_agent_b) > MINIMUM_AIR_TO_SUSPEND) && \
		((private_agent_b < (1 - MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.private_agent_b) || (private_agent_b > (1 + MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.private_agent_b)))
		return FALSE

	if(total_moles() > MINIMUM_AIR_TO_SUSPEND)
		if((abs(private_temperature - sample.private_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND) && \
			((private_temperature < (1 - MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND) * sample.private_temperature) || (private_temperature > (1 + MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND) * sample.private_temperature)))
			return FALSE
	return TRUE

/datum/gas_mixture/proc/check_turf_total(turf/model) //I want this proc to die a painful death
	var/delta_oxygen = (private_oxygen - model.oxygen)
	var/delta_carbon_dioxide = (private_carbon_dioxide - model.carbon_dioxide)
	var/delta_nitrogen = (private_nitrogen - model.nitrogen)
	var/delta_toxins = (private_toxins - model.toxins)
	var/delta_sleeping_agent = (private_sleeping_agent - model.sleeping_agent)
	var/delta_agent_b = (private_agent_b - model.agent_b)

	var/delta_temperature = (private_temperature - model.temperature)

	if(((abs(delta_oxygen) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_oxygen) >= private_oxygen * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_carbon_dioxide) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_carbon_dioxide) >= private_carbon_dioxide * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_nitrogen) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_nitrogen) >= private_nitrogen * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_toxins) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_toxins) >= private_toxins * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_sleeping_agent) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_sleeping_agent) >= private_sleeping_agent * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_agent_b) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_agent_b) >= private_agent_b * MINIMUM_AIR_RATIO_TO_SUSPEND)))
		return FALSE
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND)
		return FALSE

	return TRUE

	///Performs various reactions such as combustion or fusion (LOL)
	///Returns: TRUE if any reaction took place; FALSE otherwise
/datum/gas_mixture/proc/react(atom/dump_location)
	var/reacting = FALSE //set to TRUE if a notable reaction occured (used by pipe_network)

	if((private_agent_b > MINIMUM_MOLE_COUNT) && private_temperature > AGENT_B_CONVERSION_MIN_TEMP)
		if(private_toxins > MINIMUM_HEAT_CAPACITY && private_carbon_dioxide > MINIMUM_HEAT_CAPACITY)
			var/reaction_rate = min(private_carbon_dioxide * 0.75, private_toxins * 0.25, private_agent_b * 0.05)
			var/old_heat_capacity = heat_capacity()
			var/energy_released = reaction_rate * AGENT_B_CONVERSION_ENERGY_RELEASED

			private_carbon_dioxide -= reaction_rate
			private_oxygen += reaction_rate

			private_agent_b -= reaction_rate * 0.05

			var/new_heat_capacity = heat_capacity()
			if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
				private_temperature = (private_temperature * old_heat_capacity + energy_released) / new_heat_capacity

			reacting = TRUE

	if((private_sleeping_agent > MINIMUM_MOLE_COUNT) && private_temperature > N2O_DECOMPOSITION_MIN_ENERGY)
		var/energy_released = 0
		var/old_heat_capacity = heat_capacity()
		var/burned_fuel = 0
		burned_fuel = min((1 - (N2O_DECOMPOSITION_COEFFICIENT_A  / ((private_temperature + N2O_DECOMPOSITION_COEFFICIENT_C) ** 2))) * private_sleeping_agent, private_sleeping_agent)
		private_sleeping_agent -= burned_fuel

		if(burned_fuel)
			energy_released += (N2O_DECOMPOSITION_ENERGY_RELEASED * burned_fuel)

			private_oxygen += burned_fuel * 0.5
			private_nitrogen += burned_fuel

			var/new_heat_capacity = heat_capacity()
			if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
				private_temperature = (private_temperature * old_heat_capacity + energy_released) / new_heat_capacity
			reacting = TRUE

	fuel_burnt = 0
	//Handle plasma burning
	if((private_toxins > MINIMUM_MOLE_COUNT) && (private_oxygen > MINIMUM_MOLE_COUNT) && private_temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		var/energy_released = 0
		var/old_heat_capacity = heat_capacity()
		var/plasma_burn_rate = 0
		var/private_oxygen_burn_rate = 0
		//more plasma released at higher temperatures
		var/private_temperature_scale = 0

		if(private_temperature > PLASMA_UPPER_TEMPERATURE)
			private_temperature_scale = 1
		else
			private_temperature_scale = (private_temperature - PLASMA_MINIMUM_BURN_TEMPERATURE) / (PLASMA_UPPER_TEMPERATURE - PLASMA_MINIMUM_BURN_TEMPERATURE)
		if(private_temperature_scale > 0)
			private_oxygen_burn_rate = OXYGEN_BURN_RATE_BASE - private_temperature_scale
			if(private_oxygen > private_toxins * PLASMA_OXYGEN_FULLBURN)
				plasma_burn_rate = (private_toxins * private_temperature_scale) / PLASMA_BURN_RATE_DELTA
			else
				plasma_burn_rate = (private_temperature_scale * (private_oxygen / PLASMA_OXYGEN_FULLBURN)) / PLASMA_BURN_RATE_DELTA
			if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
				plasma_burn_rate = min(plasma_burn_rate, private_toxins, private_oxygen / private_oxygen_burn_rate) //Ensures matter is conserved properly
				private_toxins = QUANTIZE(private_toxins - plasma_burn_rate)
				private_oxygen = QUANTIZE(private_oxygen - (plasma_burn_rate * private_oxygen_burn_rate))
				private_carbon_dioxide += plasma_burn_rate

				energy_released += FIRE_PLASMA_ENERGY_RELEASED * (plasma_burn_rate)

				fuel_burnt += (plasma_burn_rate) * (1 + private_oxygen_burn_rate)

		if(energy_released > 0)
			var/new_heat_capacity = heat_capacity()
			if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
				private_temperature = (private_temperature * old_heat_capacity + energy_released) / new_heat_capacity

		if(fuel_burnt)
			reacting = TRUE

	set_dirty()
	return reacting

///Takes the amount of the gas you want to PP as an argument
///So I don't have to do some hacky switches/defines/magic strings
///eg:
///Tox_PP = get_partial_pressure(gas_mixture.toxins)
///O2_PP = get_partial_pressure(gas_mixture.oxygen)

/datum/gas_mixture/proc/get_breath_partial_pressure(gas_pressure)
	return (gas_pressure * R_IDEAL_GAS_EQUATION * private_temperature) / BREATH_VOLUME

///inverse
/datum/gas_mixture/proc/get_true_breath_pressure(partial_pressure)
	return (partial_pressure * BREATH_VOLUME) / (R_IDEAL_GAS_EQUATION * private_temperature)

/datum/gas_mixture/proc/copy_from_milla(list/milla)
	private_oxygen = milla[MILLA_INDEX_OXYGEN]
	private_carbon_dioxide = milla[MILLA_INDEX_CARBON_DIOXIDE]
	private_nitrogen = milla[MILLA_INDEX_NITROGEN]
	private_toxins = milla[MILLA_INDEX_TOXINS]
	private_sleeping_agent = milla[MILLA_INDEX_SLEEPING_AGENT]
	private_agent_b = milla[MILLA_INDEX_AGENT_B]
	innate_heat_capacity = milla[MILLA_INDEX_INNATE_HEAT_CAPACITY]
	private_temperature = milla[MILLA_INDEX_TEMPERATURE]
	private_hotspot_temperature = milla[MILLA_INDEX_HOTSPOT_TEMPERATURE]
	private_hotspot_volume = milla[MILLA_INDEX_HOTSPOT_VOLUME]
	private_fuel_burnt = milla[MILLA_INDEX_FUEL_BURNT]

/proc/share_many_airs(list/mixtures, atom/root)
	var/total_volume = 0
	var/total_oxygen = 0
	var/total_nitrogen = 0
	var/total_toxins = 0
	var/total_carbon_dioxide = 0
	var/total_sleeping_agent = 0
	var/total_agent_b = 0
	var/must_share = FALSE

	// Collect all the cheap data and check if there's a significant temperature difference.
	var/temperature = null
	for(var/datum/gas_mixture/G in mixtures)
		if(QDELETED(G))
			continue
		total_volume += G.volume

		if(isnull(temperature))
			temperature = G.private_temperature
		else if(abs(temperature - G.private_temperature) >= 1)
			must_share = TRUE

		total_oxygen += G.private_oxygen
		total_nitrogen += G.private_nitrogen
		total_toxins += G.private_toxins
		total_carbon_dioxide += G.private_carbon_dioxide
		total_sleeping_agent += G.private_sleeping_agent
		total_agent_b += G.private_agent_b

	if(total_volume == 0)
		return

	if(total_volume < 0 || isnan(total_volume) || !isnum(total_volume) || total_oxygen < 0 || isnan(total_oxygen) || !isnum(total_oxygen) || total_nitrogen < 0 || isnan(total_nitrogen) || !isnum(total_nitrogen) || total_toxins < 0 || isnan(total_toxins) || !isnum(total_toxins) || total_carbon_dioxide < 0 || isnan(total_carbon_dioxide) || !isnum(total_carbon_dioxide) || total_sleeping_agent < 0 || isnan(total_sleeping_agent) || !isnum(total_sleeping_agent) || total_agent_b < 0 || isnan(total_agent_b) || !isnum(total_agent_b))
		CRASH("A pipenet with [length(mixtures)] connected airs is corrupt and cannot flow safely. Pipenet root is [root] at ([root.x], [root.y], [root.z]).")

	// If we don't have a significant temperature difference, check for a significant gas amount difference.
	if(!must_share)
		for(var/datum/gas_mixture/G in mixtures)
			if(QDELETED(G))
				continue
			if(abs(G.private_oxygen - total_oxygen * G.volume / total_volume) > 0.1)
				must_share = TRUE
				break
			if(abs(G.private_nitrogen - total_nitrogen * G.volume / total_volume) > 0.1)
				must_share = TRUE
				break
			if(abs(G.private_toxins - total_toxins * G.volume / total_volume) > 0.1)
				must_share = TRUE
				break
			if(abs(G.private_carbon_dioxide - total_carbon_dioxide * G.volume / total_volume) > 0.1)
				must_share = TRUE
				break
			if(abs(G.private_sleeping_agent - total_sleeping_agent * G.volume / total_volume) > 0.1)
				must_share = TRUE
				break
			if(abs(G.private_agent_b - total_agent_b * G.volume / total_volume) > 0.1)
				must_share = TRUE
				break

	if(!must_share)
		// Nothing significant, don't do any more work.
		return

	// Collect the more expensive data.
	var/total_thermal_energy = 0
	var/total_heat_capacity = 0
	for(var/datum/gas_mixture/G in mixtures)
		if(QDELETED(G))
			continue
		var/heat_capacity = G.heat_capacity()
		total_heat_capacity += heat_capacity
		total_thermal_energy += G.private_temperature * heat_capacity

	// Calculate shared temperature.
	temperature = TCMB
	if(total_heat_capacity > 0)
		temperature = total_thermal_energy/total_heat_capacity

	if(temperature <= 0 || isnan(temperature) || !isnum(temperature))
		CRASH("A pipenet with [length(mixtures)] connected airs is corrupt and cannot flow safely. Pipenet root is [root] at ([root.x], [root.y], [root.z]).")

	// Update individual gas_mixtures by volume ratio.
	for(var/datum/gas_mixture/G in mixtures)
		if(QDELETED(G))
			continue
		G.private_oxygen = total_oxygen * G.volume / total_volume
		G.private_nitrogen = total_nitrogen * G.volume / total_volume
		G.private_toxins = total_toxins * G.volume / total_volume
		G.private_carbon_dioxide = total_carbon_dioxide * G.volume / total_volume
		G.private_sleeping_agent = total_sleeping_agent * G.volume / total_volume
		G.private_agent_b = total_agent_b * G.volume / total_volume

		G.private_temperature = temperature
		// In theory, we should G.set_dirty() here, but that's only useful for bound mixtures, and these can't be.

/datum/gas_mixture/proc/hotspot_expose(temperature, volume)
	return

#undef SPECIFIC_HEAT_TOXIN
#undef SPECIFIC_HEAT_AIR
#undef SPECIFIC_HEAT_CDO
#undef SPECIFIC_HEAT_N2O
#undef SPECIFIC_HEAT_AGENT_B
#undef HEAT_CAPACITY_CALCULATION
#undef MINIMUM_HEAT_CAPACITY
#undef MINIMUM_MOLE_COUNT
#undef QUANTIZE

/datum/gas_mixture/bound_to_turf
	synchronized = FALSE
	var/dirty = FALSE
	var/lastread = 0
	var/turf/bound_turf = null
	var/datum/gas_mixture/readonly/readonly = null

/datum/gas_mixture/bound_to_turf/Destroy()
	bound_turf = null
	return ..()

/datum/gas_mixture/bound_to_turf/set_dirty()
	dirty = TRUE

	if(!isnull(readonly))
		readonly.private_oxygen = private_oxygen
		readonly.private_carbon_dioxide = private_carbon_dioxide
		readonly.private_nitrogen = private_nitrogen
		readonly.private_toxins = private_toxins
		readonly.private_sleeping_agent = private_sleeping_agent
		readonly.private_agent_b = private_agent_b
		readonly.private_temperature = private_temperature
		readonly.private_hotspot_temperature = private_hotspot_temperature
		readonly.private_hotspot_volume = private_hotspot_volume
		readonly.private_fuel_burnt = private_fuel_burnt

	if(istype(bound_turf, /turf/simulated))
		var/turf/simulated/S = bound_turf
		S.update_visuals()
	ASSERT(SSair.is_in_milla_safe_code())

/datum/gas_mixture/bound_to_turf/set_oxygen(value)
	private_oxygen = value
	set_dirty()

/datum/gas_mixture/bound_to_turf/set_carbon_dioxide(value)
	private_carbon_dioxide = value
	set_dirty()

/datum/gas_mixture/bound_to_turf/set_nitrogen(value)
	private_nitrogen = value
	set_dirty()

/datum/gas_mixture/bound_to_turf/set_toxins(value)
	private_toxins = value
	set_dirty()

/datum/gas_mixture/bound_to_turf/set_sleeping_agent(value)
	private_sleeping_agent = value
	set_dirty()

/datum/gas_mixture/bound_to_turf/set_agent_b(value)
	private_agent_b = value
	set_dirty()

/datum/gas_mixture/bound_to_turf/set_temperature(value)
	private_temperature = value
	set_dirty()

/datum/gas_mixture/bound_to_turf/hotspot_expose(temperature, volume)
	if(temperature > private_temperature)
		set_dirty()
		private_hotspot_temperature = max(private_hotspot_temperature, temperature)
		private_hotspot_volume = max(private_hotspot_volume, (volume / CELL_VOLUME))

/datum/gas_mixture/bound_to_turf/proc/private_unsafe_write()
	set_tile_atmos(bound_turf, oxygen = private_oxygen, carbon_dioxide = private_carbon_dioxide, nitrogen = private_nitrogen, toxins = private_toxins, sleeping_agent = private_sleeping_agent, agent_b = private_agent_b, temperature = private_temperature)

/datum/gas_mixture/bound_to_turf/proc/get_readonly()
	if(isnull(readonly))
		readonly = new(src)
	return readonly

/// A gas mixture that should not be modified after creation.
/datum/gas_mixture/readonly

/datum/gas_mixture/readonly/New(datum/gas_mixture/parent)
	private_oxygen = parent.private_oxygen
	private_carbon_dioxide = parent.private_carbon_dioxide
	private_nitrogen = parent.private_nitrogen
	private_toxins = parent.private_toxins
	private_sleeping_agent = parent.private_sleeping_agent
	private_agent_b = parent.private_agent_b

	private_temperature = parent.private_temperature
	private_hotspot_temperature = parent.private_hotspot_temperature
	private_hotspot_volume = parent.private_hotspot_volume
	private_fuel_burnt = parent.private_fuel_burnt

/datum/gas_mixture/readonly/set_dirty()
	CRASH("Attempted to modify a readonly gas_mixture.")

/datum/gas_mixture/readonly/set_oxygen(value)
	CRASH("Attempted to modify a readonly gas_mixture.")

/datum/gas_mixture/readonly/set_carbon_dioxide(value)
	CRASH("Attempted to modify a readonly gas_mixture.")

/datum/gas_mixture/readonly/set_nitrogen(value)
	CRASH("Attempted to modify a readonly gas_mixture.")

/datum/gas_mixture/readonly/set_toxins(value)
	CRASH("Attempted to modify a readonly gas_mixture.")

/datum/gas_mixture/readonly/set_sleeping_agent(value)
	CRASH("Attempted to modify a readonly gas_mixture.")

/datum/gas_mixture/readonly/set_agent_b(value)
	CRASH("Attempted to modify a readonly gas_mixture.")

/datum/gas_mixture/readonly/set_temperature(value)
	CRASH("Attempted to modify a readonly gas_mixture.")
