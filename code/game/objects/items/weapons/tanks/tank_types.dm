/* Types of tanks!
 * Contains:
 *		Oxygen
 *		Anesthetic
 *		Air
 *		Plasma
 *		Emergency Oxygen
 */

/*
 * Oxygen
 */
/obj/item/tank/oxygen
	name = "oxygen tank"
	desc = "A tank of oxygen."
	icon_state = "oxygen"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD


/obj/item/tank/oxygen/New()
	..()
	air_contents.oxygen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/oxygen/examine(mob/user)
	if(..(user, 0))
		if(air_contents.oxygen < 10)
			to_chat(user, text("<span class='danger'>The meter on the [src.name] indicates you are almost out of air!</span>"))
			//playsound(usr, 'sound/effects/alert.ogg', 50, 1)

obj/item/tank/oxygen/empty/New()
	..()
	air_contents.oxygen = null

/obj/item/tank/oxygen/yellow
	desc = "A tank of oxygen, this one is yellow."
	icon_state = "oxygen_f"

/obj/item/tank/oxygen/red
	desc = "A tank of oxygen, this one is red."
	icon_state = "oxygen_fr"


/*
 * Anesthetic
 */
/obj/item/tank/anesthetic
	name = "anesthetic tank"
	desc = "A tank with an N2O/O2 gas mix."
	icon_state = "anesthetic"
	item_state = "an_tank"

/obj/item/tank/anesthetic/New()
	..()

	air_contents.oxygen = (3*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD

	var/datum/gas/sleeping_agent/trace_gas = new()
	trace_gas.moles = (3*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD

	air_contents.trace_gases += trace_gas

/*
 * Air
 */
/obj/item/tank/air
	name = "air tank"
	desc = "Mixed anyone?"
	icon_state = "air"
	item_state = "air"

/obj/item/tank/air/examine(mob/user)
	if(..(user, 0))
		if(air_contents.oxygen < 1 && loc==usr)
			to_chat(user, "<span class='danger'>The meter on the [src.name] indicates you are almost out of air!</span>")
			user << sound('sound/effects/alert.ogg')

/obj/item/tank/air/New()
	..()
	air_contents.oxygen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD
	air_contents.nitrogen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD

/*
 * Plasma
 */
/obj/item/tank/plasma
	name = "plasma tank"
	desc = "Contains dangerous plasma. Do not inhale. Warning: extremely flammable."
	icon_state = "plasma"
	flags = CONDUCT
	slot_flags = null	//they have no straps!

/obj/item/tank/plasma/New()
	..()
	air_contents.toxins = (3*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/plasma/attackby(obj/item/W as obj, mob/user as mob, params)
	..()

	if(istype(W, /obj/item/flamethrower))
		var/obj/item/flamethrower/F = W
		if((!F.status)||(F.ptank))	return
		master = F
		F.ptank = src
		user.unEquip(src)
		loc = F
		F.update_icon()

/obj/item/tank/plasma/full/New()
	..()
	air_contents.toxins = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/plasma/plasmaman
	desc = "The lifeblood of plasmamen.  Warning:  Extremely flammable, do not inhale (unless you're a plasman)."
	icon_state = "plasma_fr"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD

/obj/item/tank/plasma/plasmaman/examine(mob/user)
	if(..(user, 0))
		if(air_contents.toxins < 0.2 && loc==usr)
			to_chat(user, text("<span class='danger'>The meter on the [src.name] indicates you are almost out of plasma!</span>"))
			user << sound('sound/effects/alert.ogg')

/*
 * Emergency Oxygen
 */
/obj/item/tank/emergency_oxygen
	name = "emergency oxygen tank"
	desc = "Used for emergencies. Contains very little oxygen, so try to conserve it until you actually need it."
	icon_state = "emergency"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	force = 4.0
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	volume = 3 //Tiny. Real life equivalents only have 21 breaths of oxygen in them. They're EMERGENCY tanks anyway -errorage (dangercon 2011)


/obj/item/tank/emergency_oxygen/New()
	..()
	air_contents.oxygen = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/emergency_oxygen/examine(mob/user)
	if(..(user, 0))
		if(air_contents.oxygen < 0.2 && loc==usr)
			to_chat(user, text("<span class='danger'>The meter on the [src.name] indicates you are almost out of air!</span>"))
			user << sound('sound/effects/alert.ogg')

obj/item/tank/emergency_oxygen/empty/New()
	..()
	air_contents.oxygen = null

/obj/item/tank/emergency_oxygen/engi
	name = "extended-capacity emergency oxygen tank"
	icon_state = "emergency_engi"
	volume = 6

obj/item/tank/emergency_oxygen/engi/empty/New()
	..()
	air_contents.oxygen = null

/obj/item/tank/emergency_oxygen/syndi
	name = "suspicious emergency oxygen tank"
	icon_state = "emergency_syndi"
	desc = "A dark emergency oxygen tank. The label on the back reads \"Original Oxygen Tank Design, Do Not Steal.\""
	volume = 6

/obj/item/tank/emergency_oxygen/double
	name = "double emergency oxygen tank"
	icon_state = "emergency_double"
	volume = 10

obj/item/tank/emergency_oxygen/double/empty/New()
	..()
	air_contents.oxygen = null

/obj/item/tank/emergency_oxygen/double/full
	name = "pressurized double emergency oxygen tank"
	desc = "Used for \"emergencies,\" it actually contains a fair amount of oxygen."

/obj/item/tank/emergency_oxygen/double/full/New()
	..()
	air_contents.oxygen = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/*
 * Nitrogen
 */
/obj/item/tank/nitrogen
	name = "nitrogen tank"
	desc = "A tank of nitrogen."
	icon_state = "oxygen_fr"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD


/obj/item/tank/nitrogen/New()
	..()
	air_contents.nitrogen = (3*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/nitrogen/examine(mob/user)
	if(..(user, 0))
		if(air_contents.nitrogen < 10)
			to_chat(user, text("<span class='danger'>The meter on the [src.name] indicates you are almost out of air!</span>"))
			//playsound(usr, 'sound/effects/alert.ogg', 50, 1)

/obj/item/tank/emergency_oxygen/vox
	name = "vox specialized nitrogen tank"
	desc = "A high-tech nitrogen tank designed specifically for Vox."
	icon_state = "emergency_vox"
	volume = 25

/obj/item/tank/emergency_oxygen/vox/New()
	..()
	air_contents.oxygen -= (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
	air_contents.nitrogen = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/emergency_oxygen/nitrogen
	name = "emergency nitrogen tank"
	desc = "An emergency tank designed specifically for Vox."
	icon_state = "emergency_nitrogen"
	volume = 3

/obj/item/tank/emergency_oxygen/nitrogen/New()
	..()
	air_contents.oxygen -= (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
	air_contents.nitrogen = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/emergency_oxygen/plasma
	name = "emergency plasma tank"
	desc = "An emergency tank designed specifically for Plasmamen."
	icon_state = "emergency_p"
	volume = 3

/obj/item/tank/emergency_oxygen/plasma/New()
	..()
	air_contents.oxygen -= (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
	air_contents.toxins = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
