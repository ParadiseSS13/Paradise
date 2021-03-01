/**
 * # physiology datum
 *
 * Datum that stores several modifiers in a way that isn't cleared by changing species
 *
 */
/datum/physiology
	/// % of brute damage taken from all sources
	var/brute_mod = 1
	/// % of burn damage taken from all sources
	var/burn_mod = 1
	/// % of toxin damage taken from all sources
	var/tox_mod = 1
	/// % of oxygen damage taken from all sources
	var/oxy_mod = 1
	/// % of clone damage taken from all sources
	var/clone_mod = 1
	/// % of stamina damage taken from all sources
	var/stamina_mod = 1
	/// % of brain damage taken from all sources
	var/brain_mod = 1

	/// % of brute damage taken from low or high pressure (stacks with brute_mod)
	var/pressure_mod = 1
	/// % of burn damage taken from heat (stacks with burn_mod)
	var/heat_mod = 1
	/// % of burn damage taken from cold (stacks with burn_mod)
	var/cold_mod = 1

	/// %damage reduction from all sources
	var/damage_resistance = 0

	/// resistance to shocks
	var/siemens_coeff = 1

	/// % stun modifier
	var/stun_mod = 1
	/// % bleeding modifier
	var/bleed_mod = 1
	/// internal armor datum
	var/datum/armor/armor
	///% of hunger rate taken per tick.
	var/hunger_mod = 1

/datum/physiology/New()
	armor = new
