/datum/fluid
	/// What is our fluid called
	var/fluid_name = "ant fluid idk" // ants are bugs ... right?
	/// ID of our fluid for easier checking
	var/fluid_id = "antfluid"
	/// Barrel iconstate
	var/barrel_state = "base"
	/// How much of our fluid do we have
	var/fluid_amount = 0
	/// How good is our fluid at being burned as shuttle fuel? Higher is better
	var/fuel_value = 0
	/// Can we explode? Anything higher than 1 will increase the explosion size
	var/explosion_value = 0

/datum/fluid/New(amount)
	. = ..()
	fluid_amount = max(0, amount)

/datum/fluid/raw_plasma
	fluid_name = "unrefined plasma"
	fluid_id = "unr_pl"
	explosion_value = 1

/datum/fluid/refined_plasma
	fluid_name = "refined plasma"
	fluid_id ="ref_pl"
	fuel_value = 1 // Doesn't actually make the shuttle faster than default
	explosion_value = 2

/datum/fluid/fuel
	fluid_name = "basic fuel"
	fluid_id = "b_fuel"
	fuel_value = 2
	explosion_value = 2

/datum/fluid/fuel/turbo
	fluid_name = "turbofuel"
	fluid_id = "tur_fuel"
	fuel_value = 4
	explosion_value = 3

// General waste fluid
/datum/fluid/waste
	fluid_name = "waste"
	fluid_id = "waste"

// Just water
/datum/fluid/water
	fluid_name = "water"
	fluid_id = "water"
	barrel_state = "water_band"

// Salty, used as a catalysator.
/datum/fluid/brine
	fluid_name = "brine"
	fluid_id = "brine"
	barrel_state = "water_band"

// MURICA DETECTED
// Basic oil, is unrefined
/datum/fluid/oil
	fluid_name = "unrefined oil"
	fluid_id = "oil"
	barrel_state = "oil"
	explosion_value = 1

/datum/fluid/ref_oil
	fluid_name = "refined oil"
	fluid_id = "ref_oil"
	explosion_value = 2

/datum/fluid/viscous_oil
	fluid_name = "viscous oil"
	fluid_id = "visc_oil"
	explosion_value = 1
