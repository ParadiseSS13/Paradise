/* Types of tanks!
 * Contains:
 *		Oxygen
 *		Anesthetic
 *		Air
 *		Plasma
 *		Emergency Oxygen
 *		Generic
 */

/*
 * Oxygen
 */
/obj/item/tank/internals/oxygen
	name = "oxygen tank"
	desc = "A tank of oxygen, this one is blue."
	icon_state = "oxygen"
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
	force = 10
	dog_fashion = /datum/dog_fashion/back

/obj/item/tank/internals/oxygen/populate_gas()
	air_contents.oxygen = (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)

/obj/item/tank/internals/oxygen/yellow
	desc = "A tank of oxygen, this one is yellow."
	icon_state = "oxygen_f"
	dog_fashion = null

/obj/item/tank/internals/oxygen/red
	desc = "A tank of oxygen, this one is red."
	icon_state = "oxygen_fr"
	dog_fashion = null

/obj/item/tank/internals/oxygen/empty/populate_gas()
	return

/*
 * Anesthetic
 */
/obj/item/tank/internals/anesthetic
	name = "anesthetic tank"
	desc = "A tank with an N2O/O2 gas mix."
	icon_state = "anesthetic"
	item_state = "an_tank"
	force = 10

/obj/item/tank/internals/anesthetic/populate_gas()
	air_contents.oxygen = (3 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C) * O2STANDARD
	air_contents.sleeping_agent = (3 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C) * N2STANDARD

/*
 * Plasma
 */
/obj/item/tank/internals/plasma
	name = "plasma tank"
	desc = "Contains dangerous plasma. Do not inhale. Warning: extremely flammable."
	icon_state = "plasma"
	flags = CONDUCT
	slot_flags = null	//they have no straps!
	force = 8

/obj/item/tank/internals/plasma/populate_gas()
	air_contents.toxins = (3 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)

/obj/item/tank/internals/plasma/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/flamethrower))
		var/obj/item/flamethrower/F = I
		if((!F.status)||(F.ptank))
			return
		master = F
		F.ptank = src
		user.unEquip(src)
		loc = F
		F.update_icon()
	else
		return ..()

/obj/item/tank/internals/plasma/full/populate_gas()
	air_contents.toxins = (10 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)

/obj/item/tank/internals/plasma/empty/populate_gas()
	return

/*
 * Plasmaman Plasma Tank
 */
/obj/item/tank/internals/plasmaman
	name = "plasma internals tank"
	desc = "A tank of plasma gas designed specifically for use as internals, particularly for plasma-based lifeforms. If you're not a Plasmaman, you probably shouldn't use this."
	icon_state = "plasma_fr"
	item_state = "plasma_fr"
	force = 10
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE

/obj/item/tank/internals/plasmaman/populate_gas()
	air_contents.toxins = (3 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)

/obj/item/tank/internals/plasmaman/full/populate_gas()
	air_contents.toxins = (10 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)


/obj/item/tank/internals/plasmaman/belt
	icon_state = "plasmaman_tank_belt"
	item_state = "plasmaman_tank_belt"
	slot_flags = SLOT_FLAG_BELT
	flags_2 = ALLOW_BELT_NO_JUMPSUIT_2
	force = 5
	volume = 35
	w_class = WEIGHT_CLASS_SMALL

/obj/item/tank/internals/plasmaman/belt/full/populate_gas()
	air_contents.toxins = (10 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)

/obj/item/tank/internals/plasmaman/belt/empty/populate_gas()
	return

/obj/item/tank/internals/emergency_oxygen/plasma
	name = "emergency plasma tank"
	desc = "An emergency tank designed specifically for Plasmamen."
	icon_state = "emergency_p"

/obj/item/tank/internals/emergency_oxygen/plasma/populate_gas()
	air_contents.toxins = (10 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)

/*
 * Emergency Oxygen
 */
/obj/item/tank/internals/emergency_oxygen
	name = "emergency oxygen tank"
	desc = "Used for emergencies. Contains very little oxygen, so try to conserve it until you actually need it."
	icon_state = "emergency"
	flags = CONDUCT
	slot_flags = SLOT_FLAG_BELT
	flags_2 = ALLOW_BELT_NO_JUMPSUIT_2
	w_class = WEIGHT_CLASS_SMALL
	force = 4
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
	volume = 3 //Tiny. Real life equivalents only have 21 breaths of oxygen in them. They're EMERGENCY tanks anyway -errorage (dangercon 2011)

/obj/item/tank/internals/emergency_oxygen/populate_gas()
	air_contents.oxygen = (10 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)

/obj/item/tank/internals/emergency_oxygen/empty/populate_gas()
	return

/obj/item/tank/internals/emergency_oxygen/engi
	name = "extended-capacity emergency oxygen tank"
	icon_state = "emergency_engi"
	volume = 6 // should last 24 minutes if full

/obj/item/tank/internals/emergency_oxygen/engi/empty/populate_gas()
	return

/obj/item/tank/internals/emergency_oxygen/engi/syndi
	name = "suspicious emergency oxygen tank"
	icon_state = "emergency_syndi"
	desc = "A dark emergency oxygen tank. The label on the back reads \"Original Oxygen Tank Design, Do Not Steal.\""

/obj/item/tank/internals/emergency_oxygen/double
	name = "double emergency oxygen tank"
	icon_state = "emergency_double"
	volume = 12 //If it's double of the above, shouldn't it be double the volume??

/obj/item/tank/internals/emergency_oxygen/double/empty/populate_gas()
	return

/*
 * Nitrogen
 */
/obj/item/tank/internals/nitrogen
	name = "nitrogen tank"
	desc = "A tank of nitrogen."
	icon_state = "oxygen_fr"
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE

/obj/item/tank/internals/nitrogen/populate_gas()
	air_contents.nitrogen = (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)

/obj/item/tank/internals/emergency_oxygen/nitrogen
	name = "emergency nitrogen tank"
	desc = "An emergency tank designed specifically for Vox."
	icon_state = "emergency_nitrogen"

/obj/item/tank/internals/emergency_oxygen/nitrogen/populate_gas()
	air_contents.nitrogen = (10 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)

/obj/item/tank/internals/emergency_oxygen/double/vox
	name = "vox specialized nitrogen tank"
	desc = "A high-tech nitrogen tank designed specifically for Vox."
	icon_state = "emergency_vox"
	volume = 35

/obj/item/tank/internals/emergency_oxygen/double/vox/populate_gas()
	air_contents.nitrogen = (10 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)

/*
 * Air Mix
 */
/obj/item/tank/internals/air
	name = "air tank"
	desc = "Mixed anyone?"
	icon_state = "air"
	item_state = "air"
	distribute_pressure = ONE_ATMOSPHERE

/obj/item/tank/internals/air/populate_gas()
	air_contents.oxygen = (3 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C) * O2STANDARD
	air_contents.nitrogen = (3 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C) * N2STANDARD

/*
 * Generic
 */
/obj/item/tank/internals/generic
	name = "gas tank"
	desc = "A generic tank used for storing and transporting gasses. Can be used for internals."
	icon_state = "generic"
	item_state = "generic"
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
	force = 10
	dog_fashion = /datum/dog_fashion/back

/obj/item/tank/internals/generic/populate_gas()
	return
