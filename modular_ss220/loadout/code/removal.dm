/* Loadout items */
/datum/gear
	/// If true, then modulary removes item from lodaout
	var/removed_from_loadout = FALSE

// Accessories
/datum/gear/accessory/pride_pin
	removed_from_loadout = TRUE

/* On-mob accessories */
/datum/sprite_accessory
	/// If true, then modulary removes item from lodaout
	var/removed_from_loadout = FALSE

// Undershirts
/datum/sprite_accessory/undershirt/shirt_trans
	removed_from_loadout = TRUE

/datum/sprite_accessory/undershirt/shirt_nonbinary
	removed_from_loadout = TRUE

/datum/sprite_accessory/undershirt/shirt_bisexual
	removed_from_loadout = TRUE

/datum/sprite_accessory/undershirt/shirt_pansexual
	removed_from_loadout = TRUE

/datum/sprite_accessory/undershirt/shirt_asexual
	removed_from_loadout = TRUE

/datum/sprite_accessory/undershirt/shirt_rainbow
	removed_from_loadout = TRUE
