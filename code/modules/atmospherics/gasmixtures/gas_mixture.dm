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

#define HEAT_CAPACITY_CALCULATION(oxygen, carbon_dioxide, nitrogen, toxins, sleeping_agent, agent_b) \
	(carbon_dioxide * SPECIFIC_HEAT_CDO + (oxygen + nitrogen) * SPECIFIC_HEAT_AIR + toxins * SPECIFIC_HEAT_TOXIN + sleeping_agent * SPECIFIC_HEAT_N2O + agent_b * SPECIFIC_HEAT_AGENT_B)

#define MINIMUM_HEAT_CAPACITY	0.0003
#define MINIMUM_MOLE_COUNT		0.01
#define QUANTIZE(variable)		(round(variable, 0.0001))

/datum/gas_mixture
	var/oxygen = 0
	var/carbon_dioxide = 0
	var/nitrogen = 0
	var/toxins = 0
	var/sleeping_agent = 0
	var/agent_b = 0

	var/volume = CELL_VOLUME

	var/temperature = 0 //in Kelvin

	var/last_share

	var/tmp/oxygen_archived
	var/tmp/carbon_dioxide_archived
	var/tmp/nitrogen_archived
	var/tmp/toxins_archived
	var/tmp/sleeping_agent_archived
	var/tmp/agent_b_archived

	var/tmp/temperature_archived

	var/tmp/fuel_burnt = 0

	//PV = nRT

	///joules per kelvin
/datum/gas_mixture/proc/heat_capacity()
	return HEAT_CAPACITY_CALCULATION(oxygen, carbon_dioxide, nitrogen, toxins, sleeping_agent, agent_b)

/datum/gas_mixture/proc/heat_capacity_archived()
	return HEAT_CAPACITY_CALCULATION(oxygen_archived, carbon_dioxide_archived, nitrogen_archived, toxins_archived, sleeping_agent_archived, agent_b_archived)

	/// Calculate moles
/datum/gas_mixture/proc/total_moles()
	var/moles = oxygen + carbon_dioxide + nitrogen + toxins + sleeping_agent + agent_b
	return moles

/datum/gas_mixture/proc/total_trace_moles()
	var/moles = agent_b
	return moles

	/// Calculate pressure in kilopascals
/datum/gas_mixture/proc/return_pressure()
	if(volume > 0)
		return total_moles() * R_IDEAL_GAS_EQUATION * temperature / volume
	return 0

	/// Calculate temperature in kelvins
/datum/gas_mixture/proc/return_temperature()
	return temperature

	/// Calculate volume in liters
/datum/gas_mixture/proc/return_volume()
	return max(0, volume)

	/// Calculate thermal energy in joules
/datum/gas_mixture/proc/thermal_energy()
	return temperature * heat_capacity()

	///Update archived versions of variables. Returns: TRUE in all cases
/datum/gas_mixture/proc/archive()
	oxygen_archived = oxygen
	carbon_dioxide_archived = carbon_dioxide
	nitrogen_archived =  nitrogen
	toxins_archived = toxins
	sleeping_agent_archived = sleeping_agent
	agent_b_archived = agent_b

	temperature_archived = temperature

	return TRUE

	///Merges all air from giver into self. Deletes giver. Returns: TRUE if we are mutable, FALSE otherwise
/datum/gas_mixture/proc/merge(datum/gas_mixture/giver)
	if(!giver)
		return FALSE

	if(abs(temperature - giver.temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity()
		var/giver_heat_capacity = giver.heat_capacity()
		var/combined_heat_capacity = giver_heat_capacity + self_heat_capacity
		if(combined_heat_capacity != 0)
			temperature = (giver.temperature * giver_heat_capacity + temperature * self_heat_capacity) / combined_heat_capacity

	oxygen += giver.oxygen
	carbon_dioxide += giver.carbon_dioxide
	nitrogen += giver.nitrogen
	toxins += giver.toxins
	sleeping_agent += giver.sleeping_agent
	agent_b += giver.agent_b

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


	removed.oxygen = QUANTIZE((oxygen / sum) * amount)
	removed.nitrogen = QUANTIZE((nitrogen/  sum) * amount)
	removed.carbon_dioxide = QUANTIZE((carbon_dioxide / sum) * amount)
	removed.toxins = QUANTIZE((toxins / sum) * amount)
	removed.sleeping_agent = QUANTIZE((sleeping_agent / sum) * amount)
	removed.agent_b = QUANTIZE((agent_b / sum) * amount)

	oxygen = max(oxygen - removed.oxygen, 0)
	nitrogen = max(nitrogen - removed.nitrogen, 0)
	carbon_dioxide = max(carbon_dioxide - removed.carbon_dioxide, 0)
	toxins = max(toxins - removed.toxins, 0)
	sleeping_agent = max(sleeping_agent - removed.sleeping_agent, 0)
	agent_b = max(agent_b - removed.agent_b, 0)

	removed.temperature = temperature

	return removed

	///Proportionally removes amount of gas from the gas_mixture.
	///Returns: gas_mixture with the gases removed
/datum/gas_mixture/proc/remove_ratio(ratio)

	if(ratio <= 0)
		return null

	ratio = min(ratio, 1)

	var/datum/gas_mixture/removed = new

	removed.oxygen = QUANTIZE(oxygen * ratio)
	removed.nitrogen = QUANTIZE(nitrogen * ratio)
	removed.carbon_dioxide = QUANTIZE(carbon_dioxide * ratio)
	removed.toxins = QUANTIZE(toxins * ratio)
	removed.sleeping_agent = QUANTIZE(sleeping_agent * ratio)
	removed.agent_b = QUANTIZE(agent_b * ratio)

	oxygen = max(oxygen - removed.oxygen, 0)
	nitrogen = max(nitrogen - removed.nitrogen, 0)
	carbon_dioxide = max(carbon_dioxide - removed.carbon_dioxide, 0)
	toxins = max(toxins - removed.toxins, 0)
	sleeping_agent = max(sleeping_agent - removed.sleeping_agent, 0)
	agent_b = max(agent_b - removed.agent_b, 0)

	removed.temperature = temperature

	return removed

	//Copies variables from sample
/datum/gas_mixture/proc/copy_from(datum/gas_mixture/sample)
	oxygen = sample.oxygen
	carbon_dioxide = sample.carbon_dioxide
	nitrogen = sample.nitrogen
	toxins = sample.toxins
	sleeping_agent = sample.sleeping_agent
	agent_b = sample.agent_b

	temperature = sample.temperature

	return TRUE

	///Copies all gas info from the turf into the gas list along with temperature
	///Returns: TRUE if we are mutable, FALSE otherwise
/datum/gas_mixture/proc/copy_from_turf(turf/model)
	oxygen = model.oxygen
	carbon_dioxide = model.carbon_dioxide
	nitrogen = model.nitrogen
	toxins = model.toxins
	sleeping_agent = model.sleeping_agent
	agent_b = model.agent_b

	//acounts for changes in temperature
	var/turf/model_parent = model.parent_type
	if(model.temperature != initial(model.temperature) || model.temperature != initial(model_parent.temperature))
		temperature = model.temperature

	return TRUE

	///Performs air sharing calculations between two gas_mixtures assuming only 1 boundary length
	///Returns: amount of gas exchanged (+ if sharer received)
/datum/gas_mixture/proc/share(datum/gas_mixture/sharer, atmos_adjacent_turfs = 4)
	if(!sharer)
		return 0
	/// Don't make calculations if there is no difference.
	if(oxygen_archived == sharer.oxygen_archived && carbon_dioxide_archived == sharer.carbon_dioxide_archived && nitrogen_archived == sharer.nitrogen_archived &&\
	toxins_archived == sharer.toxins_archived && sleeping_agent_archived == sharer.sleeping_agent_archived && agent_b_archived == sharer.agent_b_archived && temperature_archived == sharer.temperature_archived)
		return 0
	var/delta_oxygen = QUANTIZE(oxygen_archived - sharer.oxygen_archived) / (atmos_adjacent_turfs + 1)
	var/delta_carbon_dioxide = QUANTIZE(carbon_dioxide_archived - sharer.carbon_dioxide_archived) / (atmos_adjacent_turfs + 1)
	var/delta_nitrogen = QUANTIZE(nitrogen_archived - sharer.nitrogen_archived) / (atmos_adjacent_turfs + 1)
	var/delta_toxins = QUANTIZE(toxins_archived - sharer.toxins_archived) / (atmos_adjacent_turfs + 1)
	var/delta_sleeping_agent = QUANTIZE(sleeping_agent_archived - sharer.sleeping_agent_archived) / (atmos_adjacent_turfs + 1)
	var/delta_agent_b = QUANTIZE(agent_b_archived - sharer.agent_b_archived) / (atmos_adjacent_turfs + 1)

	var/delta_temperature = (temperature_archived - sharer.temperature_archived)

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

	oxygen -= delta_oxygen
	sharer.oxygen += delta_oxygen

	carbon_dioxide -= delta_carbon_dioxide
	sharer.carbon_dioxide += delta_carbon_dioxide

	nitrogen -= delta_nitrogen
	sharer.nitrogen += delta_nitrogen

	toxins -= delta_toxins
	sharer.toxins += delta_toxins

	sleeping_agent -= delta_sleeping_agent
	sharer.sleeping_agent += delta_sleeping_agent

	agent_b -= delta_agent_b
	sharer.agent_b += delta_agent_b

	var/moved_moles = (delta_oxygen + delta_carbon_dioxide + delta_nitrogen + delta_toxins + delta_sleeping_agent + delta_agent_b)
	last_share = abs(delta_oxygen) + abs(delta_carbon_dioxide) + abs(delta_nitrogen) + abs(delta_toxins) + abs(delta_sleeping_agent) + abs(delta_agent_b)

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/new_self_heat_capacity = old_self_heat_capacity + heat_capacity_sharer_to_self - heat_capacity_self_to_sharer
		var/new_sharer_heat_capacity = old_sharer_heat_capacity + heat_capacity_self_to_sharer - heat_capacity_sharer_to_self

		if(new_self_heat_capacity > MINIMUM_HEAT_CAPACITY)
			temperature = (old_self_heat_capacity * temperature - heat_capacity_self_to_sharer * temperature_archived + heat_capacity_sharer_to_self * sharer.temperature_archived) / new_self_heat_capacity

		if(new_sharer_heat_capacity > MINIMUM_HEAT_CAPACITY)
			sharer.temperature = (old_sharer_heat_capacity * sharer.temperature - heat_capacity_sharer_to_self * sharer.temperature_archived + heat_capacity_self_to_sharer * temperature_archived) / new_sharer_heat_capacity

			if(abs(old_sharer_heat_capacity) > MINIMUM_HEAT_CAPACITY)
				if(abs(new_sharer_heat_capacity / old_sharer_heat_capacity - 1) < 0.10) // <10% change in sharer heat capacity
					temperature_share(sharer, OPEN_HEAT_TRANSFER_COEFFICIENT)

	if((delta_temperature > MINIMUM_TEMPERATURE_TO_MOVE) || abs(moved_moles) > MINIMUM_MOLES_DELTA_TO_MOVE)
		var/delta_pressure = temperature_archived * (total_moles() + moved_moles) - sharer.temperature_archived * (sharer.total_moles() - moved_moles)
		return delta_pressure * R_IDEAL_GAS_EQUATION / volume

	//Similar to share(...), except the model is not modified
	//Return: amount of gas exchanged
/datum/gas_mixture/proc/mimic(turf/model, atmos_adjacent_turfs = 4) //I want this proc to die a painful death
	var/delta_oxygen = QUANTIZE(oxygen_archived - model.oxygen) / (atmos_adjacent_turfs + 1)
	var/delta_carbon_dioxide = QUANTIZE(carbon_dioxide_archived - model.carbon_dioxide) / (atmos_adjacent_turfs + 1)
	var/delta_nitrogen = QUANTIZE(nitrogen_archived - model.nitrogen) / (atmos_adjacent_turfs + 1)
	var/delta_toxins = QUANTIZE(toxins_archived - model.toxins) / (atmos_adjacent_turfs + 1)
	var/delta_sleeping_agent = QUANTIZE(sleeping_agent_archived - model.sleeping_agent) / (atmos_adjacent_turfs + 1)
	var/delta_agent_b = QUANTIZE(agent_b_archived - model.agent_b) / (atmos_adjacent_turfs + 1)

	var/delta_temperature = (temperature_archived - model.temperature)

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

	oxygen -= delta_oxygen
	carbon_dioxide -= delta_carbon_dioxide
	nitrogen -= delta_nitrogen
	toxins -= delta_toxins
	sleeping_agent -= delta_sleeping_agent
	agent_b -= delta_agent_b

	var/moved_moles = (delta_oxygen + delta_carbon_dioxide + delta_nitrogen + delta_toxins + delta_sleeping_agent + delta_agent_b)
	last_share = abs(delta_oxygen) + abs(delta_carbon_dioxide) + abs(delta_nitrogen) + abs(delta_toxins) + abs(delta_sleeping_agent) + abs(delta_agent_b)

	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/new_self_heat_capacity = old_self_heat_capacity - heat_capacity_transferred
		if(new_self_heat_capacity > MINIMUM_HEAT_CAPACITY)
			temperature = (old_self_heat_capacity * temperature - heat_capacity_transferred * temperature_archived) / new_self_heat_capacity

		temperature_mimic(model, model.thermal_conductivity)

	if((delta_temperature > MINIMUM_TEMPERATURE_TO_MOVE) || abs(moved_moles) > MINIMUM_MOLES_DELTA_TO_MOVE)
		var/delta_pressure = temperature_archived * (total_moles() + moved_moles) - model.temperature * (model.oxygen + model.carbon_dioxide + model.nitrogen + model.toxins + model.sleeping_agent + model.agent_b)
		return delta_pressure * R_IDEAL_GAS_EQUATION / volume
	else
		return 0

	//Returns: FALSE if self-check failed or TRUE if check passes
/datum/gas_mixture/proc/check_turf(turf/model, atmos_adjacent_turfs = 4) //I want this proc to die a painful death
	var/delta_oxygen = (oxygen_archived - model.oxygen) / (atmos_adjacent_turfs + 1)
	var/delta_carbon_dioxide = (carbon_dioxide_archived - model.carbon_dioxide) / (atmos_adjacent_turfs + 1)
	var/delta_nitrogen = (nitrogen_archived - model.nitrogen) / (atmos_adjacent_turfs + 1)
	var/delta_toxins = (toxins_archived - model.toxins) / (atmos_adjacent_turfs + 1)
	var/delta_sleeping_agent = (sleeping_agent_archived - model.sleeping_agent) / (atmos_adjacent_turfs + 1)
	var/delta_agent_b = (agent_b_archived - model.agent_b) / (atmos_adjacent_turfs + 1)

	var/delta_temperature = (temperature_archived - model.temperature)

	if(((abs(delta_oxygen) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_oxygen) >= oxygen_archived * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_carbon_dioxide) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_carbon_dioxide) >= carbon_dioxide_archived * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_nitrogen) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_nitrogen) >= nitrogen_archived * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_toxins) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_toxins) >= toxins_archived * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_sleeping_agent) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_sleeping_agent) >= sleeping_agent_archived * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_agent_b) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_agent_b) >= agent_b_archived * MINIMUM_AIR_RATIO_TO_SUSPEND)))
		return FALSE
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND)
		return FALSE

	return TRUE

/datum/gas_mixture/proc/temperature_mimic(turf/model, conduction_coefficient) //I want this proc to die a painful death
	var/delta_temperature = (temperature - model.temperature)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity()

		if((model.heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient * delta_temperature * \
				(self_heat_capacity * model.heat_capacity / (self_heat_capacity + model.heat_capacity))

			temperature -= heat / self_heat_capacity

	///Performs temperature sharing calculations (via conduction) between two gas_mixtures assuming only 1 boundary length
	///Returns: new temperature of the sharer
/datum/gas_mixture/proc/temperature_share(datum/gas_mixture/sharer, conduction_coefficient)

	var/delta_temperature = (temperature_archived - sharer.temperature_archived)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity_archived()
		var/sharer_heat_capacity = sharer.heat_capacity_archived()

		if((sharer_heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient*delta_temperature * \
				(self_heat_capacity * sharer_heat_capacity / (self_heat_capacity + sharer_heat_capacity))

			temperature -= heat / self_heat_capacity
			sharer.temperature += heat / sharer_heat_capacity

/datum/gas_mixture/proc/temperature_turf_share(turf/simulated/sharer, conduction_coefficient) //I want this proc to die a painful death
	var/delta_temperature = (temperature_archived - sharer.temperature)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity()

		if((sharer.heat_capacity > MINIMUM_HEAT_CAPACITY) && (self_heat_capacity > MINIMUM_HEAT_CAPACITY))
			var/heat = conduction_coefficient * delta_temperature * \
				(self_heat_capacity * sharer.heat_capacity / (self_heat_capacity + sharer.heat_capacity))

			temperature -= heat / self_heat_capacity
			sharer.temperature += heat / sharer.heat_capacity

	//Compares sample to self to see if within acceptable ranges that group processing may be enabled
/datum/gas_mixture/proc/compare(datum/gas_mixture/sample)
	if((abs(oxygen - sample.oxygen) > MINIMUM_AIR_TO_SUSPEND) && \
		((oxygen < (1 - MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.oxygen) || (oxygen > (1 + MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.oxygen)))
		return FALSE
	if((abs(nitrogen - sample.nitrogen) > MINIMUM_AIR_TO_SUSPEND) && \
		((nitrogen < (1 - MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.nitrogen) || (nitrogen > (1 + MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.nitrogen)))
		return FALSE
	if((abs(carbon_dioxide - sample.carbon_dioxide) > MINIMUM_AIR_TO_SUSPEND) && \
		((carbon_dioxide < (1 - MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.carbon_dioxide) || (carbon_dioxide > (1 + MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.carbon_dioxide)))
		return FALSE
	if((abs(toxins - sample.toxins) > MINIMUM_AIR_TO_SUSPEND) && \
		((toxins < (1 - MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.toxins) || (toxins > (1 + MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.toxins)))
		return FALSE
	if((abs(sleeping_agent - sample.sleeping_agent) > MINIMUM_AIR_TO_SUSPEND) && \
		((sleeping_agent < (1 - MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.sleeping_agent) || (sleeping_agent > (1 + MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.sleeping_agent)))
		return FALSE
	if((abs(agent_b - sample.agent_b) > MINIMUM_AIR_TO_SUSPEND) && \
		((agent_b < (1 - MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.agent_b) || (agent_b > (1 + MINIMUM_AIR_RATIO_TO_SUSPEND) * sample.agent_b)))
		return FALSE

	if(total_moles() > MINIMUM_AIR_TO_SUSPEND)
		if((abs(temperature - sample.temperature) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND) && \
			((temperature < (1 - MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND) * sample.temperature) || (temperature > (1 + MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND) * sample.temperature)))
			return FALSE
	return TRUE

/datum/gas_mixture/proc/check_turf_total(turf/model) //I want this proc to die a painful death
	var/delta_oxygen = (oxygen - model.oxygen)
	var/delta_carbon_dioxide = (carbon_dioxide - model.carbon_dioxide)
	var/delta_nitrogen = (nitrogen - model.nitrogen)
	var/delta_toxins = (toxins - model.toxins)
	var/delta_sleeping_agent = (sleeping_agent - model.sleeping_agent)
	var/delta_agent_b = (agent_b - model.agent_b)

	var/delta_temperature = (temperature - model.temperature)

	if(((abs(delta_oxygen) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_oxygen) >= oxygen * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_carbon_dioxide) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_carbon_dioxide) >= carbon_dioxide * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_nitrogen) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_nitrogen) >= nitrogen * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_toxins) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_toxins) >= toxins * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_sleeping_agent) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_sleeping_agent) >= sleeping_agent * MINIMUM_AIR_RATIO_TO_SUSPEND)) \
		|| ((abs(delta_agent_b) > MINIMUM_AIR_TO_SUSPEND) && (abs(delta_agent_b) >= agent_b * MINIMUM_AIR_RATIO_TO_SUSPEND)))
		return FALSE
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND)
		return FALSE

	return TRUE

	///Performs various reactions such as combustion or fusion (LOL)
	///Returns: TRUE if any reaction took place; FALSE otherwise
/datum/gas_mixture/proc/react(atom/dump_location)
	var/reacting = FALSE //set to TRUE if a notable reaction occured (used by pipe_network)

	if((agent_b > MINIMUM_MOLE_COUNT) && temperature > 900)
		if(toxins > MINIMUM_HEAT_CAPACITY && carbon_dioxide > MINIMUM_HEAT_CAPACITY)
			var/reaction_rate = min(carbon_dioxide * 0.75, toxins * 0.25, agent_b * 0.05)

			carbon_dioxide -= reaction_rate
			oxygen += reaction_rate

			agent_b -= reaction_rate * 0.05

			temperature += (reaction_rate * 20000) / heat_capacity()

			reacting = TRUE

	if((sleeping_agent > MINIMUM_MOLE_COUNT) && temperature > N2O_DECOMPOSITION_MIN_ENERGY)
		var/energy_released = 0
		var/old_heat_capacity = heat_capacity()
		var/burned_fuel = 0

		burned_fuel = max(0, 0.00002 * (temperature - (0.00001 * (temperature ** 2)))) * sleeping_agent
		if(sleeping_agent - burned_fuel > 0)
			sleeping_agent -= burned_fuel

			if(burned_fuel)
				energy_released += (N2O_DECOMPOSITION_ENERGY_RELEASED * burned_fuel)

				oxygen += burned_fuel * 0.5
				nitrogen += burned_fuel

				var/new_heat_capacity = heat_capacity()
				if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
					temperature = (temperature * old_heat_capacity + energy_released) / new_heat_capacity
				reacting = TRUE

	fuel_burnt = 0
	//Handle plasma burning
	if((toxins > MINIMUM_MOLE_COUNT) && (oxygen > MINIMUM_MOLE_COUNT) && temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		var/energy_released = 0
		var/old_heat_capacity = heat_capacity()
		var/plasma_burn_rate = 0
		var/oxygen_burn_rate = 0
		//more plasma released at higher temperatures
		var/temperature_scale = 0

		if(temperature > PLASMA_UPPER_TEMPERATURE)
			temperature_scale = 1
		else
			temperature_scale = (temperature - PLASMA_MINIMUM_BURN_TEMPERATURE) / (PLASMA_UPPER_TEMPERATURE - PLASMA_MINIMUM_BURN_TEMPERATURE)
		if(temperature_scale > 0)
			oxygen_burn_rate = OXYGEN_BURN_RATE_BASE - temperature_scale
			if(oxygen > toxins * PLASMA_OXYGEN_FULLBURN)
				plasma_burn_rate = (toxins * temperature_scale) / PLASMA_BURN_RATE_DELTA
			else
				plasma_burn_rate = (temperature_scale * (oxygen / PLASMA_OXYGEN_FULLBURN)) / PLASMA_BURN_RATE_DELTA
			if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
				plasma_burn_rate = min(plasma_burn_rate, toxins, oxygen / oxygen_burn_rate) //Ensures matter is conserved properly
				toxins = QUANTIZE(toxins - plasma_burn_rate)
				oxygen = QUANTIZE(oxygen - (plasma_burn_rate * oxygen_burn_rate))
				carbon_dioxide += plasma_burn_rate

				energy_released += FIRE_PLASMA_ENERGY_RELEASED * (plasma_burn_rate)

				fuel_burnt += (plasma_burn_rate) * (1 + oxygen_burn_rate)

		if(energy_released > 0)
			var/new_heat_capacity = heat_capacity()
			if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
				temperature = (temperature * old_heat_capacity + energy_released) / new_heat_capacity

		if(fuel_burnt)
			reacting = TRUE

	return reacting

///Takes the amount of the gas you want to PP as an argument
///So I don't have to do some hacky switches/defines/magic strings
///eg:
///Tox_PP = get_partial_pressure(gas_mixture.toxins)
///O2_PP = get_partial_pressure(gas_mixture.oxygen)

/datum/gas_mixture/proc/get_breath_partial_pressure(gas_pressure)
	return (gas_pressure * R_IDEAL_GAS_EQUATION * temperature) / BREATH_VOLUME

///inverse
/datum/gas_mixture/proc/get_true_breath_pressure(partial_pressure)
	return (partial_pressure * BREATH_VOLUME) / (R_IDEAL_GAS_EQUATION * temperature)

///Mathematical proofs:
/**
get_breath_partial_pressure(gas_pp) --> gas_pp/total_moles()*breath_pp = pp
get_true_breath_pressure(pp) --> gas_pp = pp/breath_pp*total_moles()

10/20*5 = 2.5
10 = 2.5/5*20
**/
