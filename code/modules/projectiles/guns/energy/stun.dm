/obj/item/gun/energy/taser
	name = "X-260 taser"
	desc = "A less-lethal pistol that fires electrodes to incapacitate targets."
	icon_state = "taser"
	item_state = null	//so the human update icon uses the icon_state instead.
	origin_tech = "combat=3"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode)
	ammo_x_offset = 3
	can_holster = TRUE  // Pistol size

/obj/item/gun/energy/taser/examine_more(mob/user)
	. = ..()
	. += "The X-270 is produced by Shellguard Munitions, based on a long line of similar less-lethal weapon systems that go back centuries. It is designed to allow law enforcement to take down noncompliant targets at a distance without having to resort to lethal force. \
	They work by firing a pair of electrodes into the target and then transmitting an electrical current through them. This electrical current is specifically modulated to interfere with the neuromuscular junction, stimulating it and forcing the muscle into the contracted position, disabling movement. \
	Disablers have mostly replaced these weapons across known space, although the remain in certain specific niches where the immediate stopping power is desired."

/obj/item/gun/energy/arc_revolver
	name = "arc revolver"
	desc = "A high-tech revolver that fires internal, reusable shock cartridges in a revolving cylinder. The cartridges can be recharged using conventional rechargers. These shots charge whatever they hit, causing arcs of electricity to form between them."
	icon_state = "stunrevolver"
	item_state = "gun"
	origin_tech = "combat=4;materials=4;powerstorage=4"
	ammo_type = list(/obj/item/ammo_casing/energy/arc_revolver)
	can_flashlight = FALSE
	shaded_charge = FALSE
	can_holster = TRUE


/obj/item/gun/energy/gun/advtaser
	name = "XD-2600 hybrid taser"
	desc = "An upgrade to Shellguard Munitions' X-260 that adds an integrated disabler for long-range takedowns. It has two modes: stun, disable."
	icon_state = "advtaser"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler)
	origin_tech = "combat=4"
	ammo_x_offset = 2
	flight_x_offset = 15
	shaded_charge = FALSE
	can_holster = TRUE  // Pistol size

/obj/item/gun/energy/gun/advtaser/examine_more(mob/user)
	. = ..()
	. += "The XD-2600 is a high-end less-lethal weapon system offered by Shellguard for those echelons that still make use of their original X-260 but also wish for the longer range offered by the disabler by simply combining both into a singular package. \
	Whilst tasers have been largely phased out by most law enforcement across known space, Shellguard continues to make a tidy profit providing these to those enforcement agencies that have not, as well as private individuals seeking a potent less-lethal self defence tool, mostly in the corporate world."

/obj/item/gun/energy/gun/advtaser/cyborg
	name = "cyborg taser"
	desc = "An integrated hybrid taser that draws directly from a cyborg's power cell. The weapon contains a limiter to prevent the cyborg's power cell from overheating."
	can_flashlight = FALSE
	can_charge = FALSE

/obj/item/gun/energy/gun/advtaser/cyborg/newshot()
	..()
	robocharge()

/obj/item/gun/energy/disabler
	name = "disabler"
	desc = "A self-defense weapon that exhausts organic targets, weakening them until they collapse."
	icon_state = "disabler"
	item_state = null
	origin_tech = "combat=3"
	ammo_type = list(/obj/item/ammo_casing/energy/disabler)
	ammo_x_offset = 2
	can_flashlight = TRUE
	flight_x_offset = 15
	flight_y_offset = 10
	can_holster = TRUE
	execution_speed = 5 SECONDS

/obj/item/gun/energy/disabler/examine_more(mob/user)
	. = ..()
	. += "The disabler is a less-than-lethal weapon designed to incapacitate targets without causing lasting harm. It was designed by Shellguard Munitions as an alternative to electroshock-based LTL weapons. \
	It's chief advantages are the longer ranges and massively reduced incidences of accidental fatalities. \
	It functions by emitting a precisely tuned ionised particle beam that is accelerated out of the barrel by a short electromagnetic coil stack. When the beam hits an organic target, it selectively disrupts ATP binding sites in the myosin heads of the myofibrils in the skeletal musculature. \
	This initially causes slowdown of muscle contractions, but continued attack will result in almost complete paralysis of most voluntary skeletal muscle groups, along with feelings of extreme lethargy and fatigue. \
	These effects are temporary and will subside soon after, causing no lasting harm. By a massive stroke of coincidence, these same particle beams also exhibit a similar effect on the motors of IPC limbs. \
	The safety and efficiency of the disabler has caused it to rapidly replace tasers in police and security forces across most of known space, although the lack of immediate stopping power has prevented a complete replacement."

/obj/item/gun/energy/disabler/Initialize(mapload)
	. = ..()
	cell.maxcharge = 800
	cell.charge = 800

/obj/item/gun/energy/disabler/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	var/obj/item/gun/energy/disabler/offhand_disabler = user.get_inactive_hand()
	if(istype(offhand_disabler) && offhand_disabler.semicd && (user.a_intent != INTENT_HARM))
		return

	return ..()

/obj/item/gun/energy/disabler/cyborg
	name = "cyborg disabler"
	desc = "An integrated disabler that draws from a cyborg's power cell. This weapon contains a limiter to prevent the cyborg's power cell from overheating."
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/cyborg)
	can_charge = FALSE

/obj/item/gun/energy/disabler/cyborg/newshot()
	..()
	robocharge()

/obj/item/gun/energy/disabler/silencer
	name = "u-ION Silencer"
	desc = "Nanotrasen's take on silenced weapons. A quiet lethal disabler, designed to make the death look like a natural cause."
	icon_state = "tesla"
	item_state = "tesla"
	origin_tech = "combat=6;syndicate=2"
	shaded_charge = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/silencer_ammo)
	suppressed = TRUE
	execution_speed = 4 SECONDS

/obj/item/gun/energy/disabler/silencer/examine_more(mob/user)
	. = ..()
	. += "Whilst the disabler is a very safe weapon that is in widespread use across the known galaxy, there are a handful of accidental fatalities that have been reported, usually due to respiratory or cardiac arrest. Nanotrasen saw these exceptional cases and saw the potential to develop a very special weapon. \
	The result of their efforts was the u-ION Silencer. Like the disabler it is based on, it utilises an ionised particle beam to efficiently paralyse targets by disrupting ATP binding in specific parts of the musculature. \
	However, it has been fine-tuned to go several steps further, and block ALL sites of ATP binding, causing subjects to rapidly expire in a similar way to if they had been given a massive dose of cyanide. \
	Critically however, the temporary nature of this disruption and the lack of any lingering chemical reagent means that the cause of death will be unclear afterwards. Whilst the paralytic nature of the weapon still functions against IPCs, it will not kill them, due to a lack of a metabolism to inhibit. \
	Agents of Nanotrasen employ this weapon to 'remove' problematic individuals without it being immediately obvious that foul play was involved."
