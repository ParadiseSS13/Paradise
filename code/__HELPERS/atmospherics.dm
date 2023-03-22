/** A simple rudimentary gasmix to information list converter. Can be used for UIs.
 * Args:
 * * gasmix: [/datum/gas_mixture]
 * * name: String used to name the list, optional.
 * Returns: A list parsed_gasmixes with the following structure:
 * - parsed_gasmixes    	Value: Assoc List     Desc: The thing we return
 * -- Key: name         	Value: String         Desc: Gasmix Name
 * -- Key: temperature  	Value: Number         Desc: Temperature in kelvins
 * -- Key: volume       	Value: Number         Desc: Volume in liters
 * -- Key: pressure     	Value: Number         Desc: Pressure in kPa
 * -- Key: oxygen			Value: Number		  Desc: Amount of mols of O2
 * -- Key: carbon_dioxide	Value: Number		  Desc: Amount of mols of CO2
 * -- Key: nitrogen			Value: Number		  Desc: Amount of mols of N2
 * -- Key: toxins			Value: Number		  Desc: Amount of mols of plasma
 * -- Key: sleeping_agent	Value: Number		  Desc: Amount of mols of N2O
 * -- Key: agent_b			Value: Number		  Desc: Amount of mols of agent B
 * -- Key: total_moles		Value: Number		  Desc: Total amount of mols in the mixture
 * Returned list should always be filled with keys even if value are nulls.
 */

//TODO: Port gas_mixture_parser from TG
/proc/gas_mixture_parser(datum/gas_mixture/gasmix, name)
	. = list(
		"oxygen" = null,
		"carbon_dioxide" = null,
		"nitrogen" = null,
		"toxins" = null,
		"sleeping_agent" = null,
		"agent_b" = null,
		"name" = format_text(name),
		"total_moles" = null,
		"temperature" = null,
		"volume"= null,
		"pressure"= null,
		"heat_capacity" = null,
		"thermal_energy" = null,
	)
	if(!gasmix)
		return
	.["oxygen"] = gasmix.oxygen
	.["carbon_dioxide"] = gasmix.carbon_dioxide
	.["nitrogen"] = gasmix.nitrogen
	.["toxins"] = gasmix.toxins
	.["sleeping_agent"] = gasmix.sleeping_agent
	.["agent_b"] = gasmix.agent_b
	.["total_moles"] = gasmix.total_moles()
	.["temperature"] = gasmix.temperature
	.["volume"] = gasmix.volume
	.["pressure"] = gasmix.return_pressure()
	.["heat_capacity"] = display_joules(gasmix.heat_capacity())
	.["thermal_energy"] = display_joules(gasmix.thermal_energy())
