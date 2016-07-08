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
/obj/item/weapon/tank/oxygen
	name = "oxygen tank"
	desc = "A tank of oxygen."
	icon_state = "oxygen"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD


	New()
		..()
		src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
		return


	examine(mob/user)
		if(..(user, 0))
			if(air_contents.oxygen < 10)
				to_chat(user, text("\red <B>The meter on the [src.name] indicates you are almost out of air!</B>"))
				//playsound(usr, 'sound/effects/alert.ogg', 50, 1)


/obj/item/weapon/tank/oxygen/yellow
	desc = "A tank of oxygen, this one is yellow."
	icon_state = "oxygen_f"

/obj/item/weapon/tank/oxygen/red
	desc = "A tank of oxygen, this one is red."
	icon_state = "oxygen_fr"


/*
 * Anesthetic
 */
/obj/item/weapon/tank/anesthetic
	name = "anesthetic tank"
	desc = "A tank with an N2O/O2 gas mix."
	icon_state = "anesthetic"
	item_state = "an_tank"

/obj/item/weapon/tank/anesthetic/New()
	..()

	src.air_contents.oxygen = (3*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD

	var/datum/gas/sleeping_agent/trace_gas = new()
	trace_gas.moles = (3*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD

	src.air_contents.trace_gases += trace_gas
	return

/*
 * Air
 */
/obj/item/weapon/tank/air
	name = "air tank"
	desc = "Mixed anyone?"
	icon_state = "oxygen"


	examine(mob/user)
		if(..(user, 0))
			if(air_contents.oxygen < 1 && loc==usr)
				to_chat(user, "\red <B>The meter on the [src.name] indicates you are almost out of air!</B>")
				user << sound('sound/effects/alert.ogg')

/obj/item/weapon/tank/air/New()
	..()

	src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD
	src.air_contents.nitrogen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD
	return

/*
 * Plasma
 */
/obj/item/weapon/tank/plasma
	name = "plasma tank"
	desc = "Contains dangerous plasma. Do not inhale. Warning: extremely flammable."
	icon_state = "plasma"
	flags = CONDUCT
	slot_flags = null	//they have no straps!

/obj/item/weapon/tank/plasma/New()
	..()
	src.air_contents.toxins = (3*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C)
	return


/obj/item/weapon/tank/plasma/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()

	if(istype(W, /obj/item/weapon/flamethrower))
		var/obj/item/weapon/flamethrower/F = W
		if((!F.status)||(F.ptank))	return
		src.master = F
		F.ptank = src
		user.unEquip(src)
		src.loc = F
		F.update_icon()
	return

/obj/item/weapon/tank/plasma/full/New()
	..()
	src.air_contents.toxins = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
	return

/obj/item/weapon/tank/plasma/plasmaman
	desc = "The lifeblood of plasmamen.  Warning:  Extremely flammable, do not inhale (unless you're a plasman)."
	icon_state = "plasma_fr"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD

/obj/item/weapon/tank/plasma/plasmaman/examine(mob/user)
	if(..(user, 0))
		if(air_contents.toxins < 0.2 && loc==usr)
			to_chat(user, text("\red <B>The meter on the [src.name] indicates you are almost out of plasma!</B>"))
			user << sound('sound/effects/alert.ogg')

/*
 * Emergency Oxygen
 */
/obj/item/weapon/tank/emergency_oxygen
	name = "emergency oxygen tank"
	desc = "Used for emergencies. Contains very little oxygen, so try to conserve it until you actually need it."
	icon_state = "emergency"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	w_class = 2.0
	force = 4.0
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	volume = 3 //Tiny. Real life equivalents only have 21 breaths of oxygen in them. They're EMERGENCY tanks anyway -errorage (dangercon 2011)


	New()
		..()
		src.air_contents.oxygen = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
		return


	examine(mob/user)
		if(..(user, 0))
			if(air_contents.oxygen < 0.2 && loc==usr)
				to_chat(user, text("\red <B>The meter on the [src.name] indicates you are almost out of air!</B>"))
				user << sound('sound/effects/alert.ogg')

/obj/item/weapon/tank/emergency_oxygen/engi
	name = "extended-capacity emergency oxygen tank"
	icon_state = "emergency_engi"
	volume = 6

/obj/item/weapon/tank/emergency_oxygen/double
	name = "double emergency oxygen tank"
	icon_state = "emergency_double"
	volume = 10

/obj/item/weapon/tank/emergency_oxygen/double/full
	name = "pressurized double emergency oxygen tank"
	desc = "Used for \"emergencies,\" it actually contains a fair amount of oxygen."

	New()
		..()
		src.air_contents.oxygen = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
		return

/*
 * Nitrogen
 */
/obj/item/weapon/tank/nitrogen
	name = "nitrogen tank"
	desc = "A tank of nitrogen."
	icon_state = "oxygen_fr"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD


/obj/item/weapon/tank/nitrogen/New()
	..()

	src.air_contents.nitrogen = (3*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C)
	return

/obj/item/weapon/tank/nitrogen/examine(mob/user)
	if(..(user, 0))
		if(air_contents.nitrogen < 10)
			to_chat(user, text("\red <B>The meter on the [src.name] indicates you are almost out of air!</B>"))
			//playsound(usr, 'sound/effects/alert.ogg', 50, 1)


/obj/item/weapon/tank/emergency_oxygen/vox
	name = "vox specialized nitrogen tank"
	desc = "A high-tech nitrogen tank designed specifically for Vox."
	icon_state = "emergency_vox"
	item_state = "emergency_vox"
	volume = 25


	New()
		..()
		src.air_contents.oxygen -= (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
		src.air_contents.nitrogen = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
		return